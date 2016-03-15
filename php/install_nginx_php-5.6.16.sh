#!/bin/bash

cd php

# download some soft
\rm -f *.bz2
if [[ $open_download_137 -eq 1 ]]; then
    wget http://115.29.97.137:8181/php-5.6.16.tar.bz2
fi

[[ -d php-5.6.16 ]] && {
    rm -rf php-5.6.16
}

[[ ! -f php-5.6.16.tar.bz2 ]] && {
    echo "Not find php/php-5.6.16.tar.bz2 file ! quit !!"
    exit 1
}

tar jxvf php-5.6.16.tar.bz2 -C .
cd php-5.6.16
./buildconf --force

if [[ "$enable_php_thread" == "true" ]]; then
./configure --prefix=/alidata/server/php \
--enable-opcache \
--with-config-file-path=/alidata/server/php/etc \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--enable-fpm \
--enable-static \
--enable-inline-optimization \
--enable-sockets \
--enable-wddx \
--enable-zip \
--enable-calendar \
--enable-bcmath \
--enable-soap \
--with-zlib \
--with-iconv \
--with-gd \
--with-xmlrpc \
--enable-mbstring \
--with-curl \
--enable-ftp \
--with-mcrypt  \
--with-freetype-dir=/usr/local/freetype.2.1.10 \
--with-jpeg-dir=/usr/local/jpeg.6 \
--with-png-dir=/usr/local/libpng.1.2.53 \
--disable-ipv6 \
--disable-debug \
--with-openssl \
--disable-session \
--enable-maintainer-zts \
--disable-fileinfo
else
./configure --prefix=/alidata/server/php \
--enable-opcache \
--with-config-file-path=/alidata/server/php/etc \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--enable-fpm \
--enable-static \
--enable-inline-optimization \
--enable-sockets \
--enable-wddx \
--enable-zip \
--enable-calendar \
--enable-bcmath \
--enable-soap \
--with-zlib \
--with-iconv \
--with-gd \
--with-xmlrpc \
--enable-mbstring \
--with-curl \
--enable-ftp \
--with-mcrypt  \
--with-freetype-dir=/usr/local/freetype.2.1.10 \
--with-jpeg-dir=/usr/local/jpeg.6 \
--with-png-dir=/usr/local/libpng.1.2.53 \
--disable-ipv6 \
--disable-debug \
--with-openssl \
--enable-maintainer-zts \
--disable-fileinfo
fi

# not use the session, use this option
# --disable-session \

CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ $CPU_NUM -gt 1 ];then
    make ZEND_EXTRA_LIBS='-liconv' -j$CPU_NUM
else
    make ZEND_EXTRA_LIBS='-liconv'
fi
make install
cd ..
# check install ok
if [[ ! -f /alidata/server/php/bin/php ]]; then
    echo "Cannot find /alidata/server/php/bin/php !!"
    echo "Maybe PHP install failed."
    exit 1
fi

# adjust php.ini
\cp ./php-5.6.16/php.ini-production /alidata/server/php/etc/php.ini

sed -i "s#; extension_dir = \"\.\/\"#extension_dir = \"/alidata/server/php/lib/php/extensions/no-debug-non-zts-${zts_num}/\"#" /alidata/server/php/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 10M/g' /alidata/server/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' /alidata/server/php/etc/php.ini
sed -i 's/;upload_tmp_dir =/upload_tmp_dir =\"\/tmp\"/' /alidata/server/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /alidata/server/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /alidata/server/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 10/g' /alidata/server/php/etc/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 100M/' /alidata/server/php/etc/php.ini 		 # very importent !!!
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_STRICT/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE \& ~E_STRICT/' /alidata/server/php/etc/php.ini
sed -i 's/html_errors = On/html_errors = Off/' /alidata/server/php/etc/php.ini

# disable the php.ini session func, by diwen
\cp /alidata/server/php/etc/php.ini /alidata/server/php/etc/php.ini.bak
sed -i "s/^\[Session\]/;\[Session\]/g" /alidata/server/php/etc/php.ini
sed -i "s/^session/;session/g" /alidata/server/php/etc/php.ini

# adjust php-fpm
\cp /alidata/server/php/etc/php-fpm.conf.default /alidata/server/php/etc/php-fpm.conf
sed -i 's,user = nobody,user = huakai,g'   /alidata/server/php/etc/php-fpm.conf
sed -i 's,group = nobody,group = huakai,g'   /alidata/server/php/etc/php-fpm.conf
sed -i 's/owner = nobody/owner = huakai/g' /alidata/server/php/etc/php-fpm.conf

sed -i 's/;log_level = notice/log_level = error/' /alidata/server/php/etc/php-fpm.conf
sed -i 's/;request_terminate_timeout = 0/request_terminate_timeout = 10/' /alidata/server/php/etc/php-fpm.conf
sed -i 's/;rlimit_files = 1024/rlimit_files = 51200/' /alidata/server/php/etc/php-fpm.conf

# default is pm = dynamic,
# if pm=static, just pm.max_children is valid
# if pm=dynamic, start_servers/min_spare_servers/max_spare_servers 3 params is valid
# compute the php-fpm process count: <your memory> / 20M * 1.5

# your memory = free -m | awk '/Mem:/{print $2}'  -- nginx keep 100M memory, other task 200M
your_mem=`free -m | awk '/Mem:/{print $2}'`

sed -i "s,^pm.max_children = 5,pm.max_children = $((($your_mem-400)/20)),g"   /alidata/server/php/etc/php-fpm.conf
sed -i "s,^pm.start_servers = 2,pm.start_servers = $((($your_mem-400)/30)),g"   /alidata/server/php/etc/php-fpm.conf
sed -i "s,^pm.min_spare_servers = 1,pm.min_spare_servers = $((($your_mem-400)/40)),g"   /alidata/server/php/etc/php-fpm.conf
sed -i "s,^pm.max_spare_servers = 3,pm.max_spare_servers = $((($your_mem-400)/20)),g"   /alidata/server/php/etc/php-fpm.conf
sed -i 's/;pm.max_requests = 500/pm.max_requests = 10000/' /alidata/server/php/etc/php-fpm.conf
sed -i 's,;pid = run/php-fpm.pid,pid = /var/run/php-fpm.pid,g'   /alidata/server/php/etc/php-fpm.conf
sed -i 's,;request_slowlog_timeout = 0,request_slowlog_timeout = 5,g'   /alidata/server/php/etc/php-fpm.conf
sed -i 's,;error_log = log/php-fpm.log,error_log = /alidata/log/php/php-fpm.log,g'   /alidata/server/php/etc/php-fpm.conf
sed -i 's,;slowlog = log/$pool.log.slow,slowlog = /alidata/log/php/php-fpm.slow.log,g'   /alidata/server/php/etc/php-fpm.conf

\cp ./php-5.6.16/sapi/fpm/init.d.php-fpm  /etc/init.d/php-fpm
# modify the php-fpm startup time
sed -i 's/-lt 35/-lt 60/' /etc/init.d/php-fpm
sed -i "s,php_fpm_PID=\${prefix}/var/run/php-fpm.pid,php_fpm_PID=/var/run/php-fpm.pid," /etc/init.d/php-fpm
chmod 755 /etc/init.d/php-fpm
chown -R huakai:huakai /alidata/server/${php_dir}

cd ..
echo "install php ok"
