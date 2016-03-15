#!/bin/bash

cat << HELP

Note this:
  Other depends module.
  memcached.so / redis.so / seaslog.so / pthreads.so (option)

HELP
sleep 2

# solve for memcached dependency
yum -y install libevent libevent-devel cyrus-sasl-plain cyrus-sasl cyrus-sasl-lib cyrus-sasl-devel

# download some soft
\rm -f *.gz
\rm -f *.tgz
\rm -f *.zip
if [[ $open_download_137 -eq 1 ]]; then
    wget http://115.29.97.137:8181/libmemcached-1.0.18.tar.gz
    wget http://115.29.97.137:8181/memcached-2.2.0.tgz
    wget http://115.29.97.137:8181/phpredis-develop.zip
    wget http://115.29.97.137:8181/pthreads-2.0.10.zip
    wget http://115.29.97.137:8181/SeasLog-master.zip
    wget http://115.29.97.137:8181/redis-3.0.3.tar.gz
fi

echo "install php - memcached.so ..."
if [[ -d libmemcached-1.0.18/ ]]; then
	\rm -rf libmemcached-1.0.18/
fi
tar zxvf libmemcached-1.0.18.tar.gz
cd libmemcached-1.0.18/
./configure --prefix=/usr/local/libmemcached --enable-sasl
make
make install
cd ..

source /etc/profile
which phpize >/dev/null 2>&1
if [[ "$?" != "0" ]]; then
	echo "cannot find phpize !! quit !!"
	exit 1
fi

if [[ -d memcached-2.2.0 ]]; then
	\rm -rf memcached-2.2.0
fi
tar zxvf memcached-2.2.0.tgz
cd memcached-2.2.0
phpize
./configure --with-libmemcached-dir=/usr/local/libmemcached --enable-memcached-sasl --disable-memcached-session
make
\cp modules/memcached.so /alidata/server/php/lib/php/extensions/no-debug-non-zts-${zts_num}/
echo "extension = memcached.so" >> /alidata/server/php/etc/php.ini
echo "memcached.use_sasl = 1" >> /alidata/server/php/etc/php.ini
cd ..

sleep 2
echo "install php - redis.so ..."
if [[ -d phpredis-develop ]]; then
	\rm -rf phpredis-develop
fi
unzip phpredis-develop.zip
cd phpredis-develop/
phpize
./configure --with-php-config=/alidata/server/php/bin/php-config --disable-redis-session
make
\cp modules/redis.so /alidata/server/php/lib/php/extensions/no-debug-non-zts-${zts_num}/
echo "extension = redis.so" >> /alidata/server/php/etc/php.ini
cd ..

if [[ "$enable_php_thread" == "true" ]]; then
	sleep 2
	echo "install php - pthreads.so ..."
	unzip pthreads-2.0.10.zip
	cd pthreads-2.0.10
	phpize
	./configure --with-php-config=/alidata/server/php/bin/php-config
	make
	\cp modules/pthreads.so /alidata/server/php/lib/php/extensions/no-debug-non-zts-${zts_num}/
	echo "extension = pthreads.so" >> /alidata/server/php/etc/php.ini
	cd ..
fi

sleep 2
echo "install php - seaslog.so ..."
if [[ -d SeasLog-master ]]; then
	\rm -rf SeasLog-master
fi
unzip SeasLog-master.zip
cd SeasLog-master
phpize
./configure --with-php-config=/alidata/server/php/bin/php-config
make
\cp modules/seaslog.so /alidata/server/php/lib/php/extensions/no-debug-non-zts-${zts_num}/

echo "; configuration for php SeasLog module" >> /alidata/server/php/etc/php.ini
echo "extension = seaslog.so" >> /alidata/server/php/etc/php.ini
echo "seaslog.default_basepath = /alidata/hk_log" >> /alidata/server/php/etc/php.ini
echo "seaslog.default_logger = api" >> /alidata/server/php/etc/php.ini
echo "seaslog.disting_type = 1" >> /alidata/server/php/etc/php.ini
echo "seaslog.disting_by_hour = 1" >> /alidata/server/php/etc/php.ini
echo "seaslog.use_buffer = 1" >> /alidata/server/php/etc/php.ini
echo "seaslog.buffer_size = 100" >> /alidata/server/php/etc/php.ini
echo "seaslog.level = 0" >> /alidata/server/php/etc/php.ini
# ;默认log根目录
# ;默认logger目录
# ;是否以type分文件 1是 0否(默认)
# ;是否每小时划分一个文件 1是 0否(默认)
# ;是否启用buffer 1是 0否(默认)
# ;buffer中缓冲数量 默认0(不使用buffer_size)
# ;记录日志级别 默认0(所有日志)
cd ..

echo ""
echo "install redis server-slave soft ..."
if [[ -d redis-3.0.3 ]]; then
	\rm -rf redis-3.0.3
fi
tar zxvf redis-3.0.3.tar.gz
cd redis-3.0.3
make PREFIX=/alidata/server/redis  install

echo "export PATH=\$PATH:/alidata/server/redis/bin" >> /etc/profile
source /etc/profile

mkdir -p /alidata/server/redis/log/
mkdir -p /alidata/server/redis/db/
touch /alidata/server/redis/log/redis.log

\cp redis.conf /etc/
sed -i "s/^daemonize no/daemonize yes/" /etc/redis.conf
sed -i "s/^# bind 127.0.0.1/bind 127.0.0.1/" /etc/redis.conf
sed -i "s/^loglevel notice/loglevel warning/" /etc/redis.conf
sed -i "s/^logfile .*/logfile \"\/alidata\/server\/redis\/log\/redis.log\"/" /etc/redis.conf
sed -i "s/^dbfilename .*/dbfilename huakai.rdb/" /etc/redis.conf
sed -i "s/^dir .*/dir \/alidata\/server\/redis\/db/" /etc/redis.conf
sed -i "s/^timeout 0/timeout 300/" /etc/redis.conf

# Here, set the redis master, this machine is slave node
if [ "$redis_is_master" != "true" ]; then
	redis_master=$(cat ../redis-master.txt | head -n 1)
	sed -i "s/^# slaveof .*/slaveof $redis_master/" /etc/redis.conf
fi

# set the maxmemory of redis is 100M
sed -i "s/^# maxmemory .*/maxmemory 50000000/" /etc/redis.conf

# startup the redis
\cp ../redis /etc/init.d/
chmod +x /etc/init.d/redis
chown -R huakai:huakai /alidata/server/redis
su - huakai /etc/init.d/redis restart

# add redis auto start on system
if [[ $(grep redis /etc/rc.local | wc -l) -eq 0 ]]; then
	echo "su - huakai /etc/init.d/redis start" >> /etc/rc.local
fi

cd ..
echo "Redis 3.0.3 server-slave start OK!"
