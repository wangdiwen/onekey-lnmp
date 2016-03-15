#!/bin/bash

cd nginx

# download some soft
\rm -f *.gz
if [[ $open_download_137 -eq 1 ]]; then
    wget http://115.29.97.137:8181/nginx-1.8.0.tar.gz
fi

if [[ -d nginx-1.8.0 ]]; then
    rm -rf nginx-1.8.0
fi

if [ ! -f nginx-1.8.0.tar.gz ];then
  wget http://nginx.org/download/nginx-1.8.0.tar.gz -O nginx-1.8.0.tar.gz
fi

tar zxvf nginx-1.8.0.tar.gz
cd nginx-1.8.0
./configure --user=huakai \
--group=huakai \
--prefix=/alidata/server/nginx \
--with-http_stub_status_module \
--without-http-cache \
--with-http_ssl_module \
--with-http_gzip_static_module

CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
cd ..

if [[ ! -d /alidata/server/nginx/logs ]]; then
    mkdir -p /alidata/server/nginx/logs
fi


\cp -fR config-nginx/* /alidata/server/nginx/conf/
sed -i "s/worker_processes  2/worker_processes  $CPU_NUM/" /alidata/server/nginx/conf/nginx.conf

chmod 755 /alidata/server/nginx/sbin/nginx
chmod 775 /alidata/server/nginx/logs

\cp /alidata/server/nginx/conf/nginx /etc/init.d/
chmod 755 /etc/init.d/nginx

cd ..
echo "install nginx ok"
