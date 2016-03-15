#!/bin/bash

cat << HELP

One key install bash script for LNMP structure, by diwen.

Linux System - CentOS 6.5 x86_64 (also support i686)
Nginx - 1.8.0
PHP   - 5.6.16
Mysql - 5.6.21

Running user: huakai / huakai123abc!@#
(if you want to clean env, run ./uninstall.sh script.)

HELP

echo "install nmap net tool ..."
if [[ $(rpm -q nmap | grep "not" | wc -l) -eq 1 ]] ; then
  yum -y install nmap
fi

# check 137 machine open 8181 download func
export open_download_137=`nmap 115.29.97.137 -p 8181 | grep open | wc -l`  # 1 -> open

export nginx_version=1.8.0
export mysql_version=5.6.21
export php_version=5.6.16
export zts_num=20151226
export web=nginx
export install_log=/alidata/install-info.log
export disable_install_mysql=false            # must be false for install mysql lib
export enable_php_thread=true                # cannot use php thread property
export web_dir=nginx-${nginx_version}
export php_dir=php-${php_version}
export redis_is_master=true
export machine=
if [ `uname -m` == "x86_64" ];then
  machine=x86_64
else
  machine=i686
fi
export mysql_dir=mysql-${mysql_version}
export ifcentos=
export ifubuntu=

read -p "Enter the y or Y to continue:" is_y
if [ "${is_y}" != "y" ] && [ "${is_y}" != "Y" ];then
  echo "Quit job."
  exit 1
fi

# echo "uninstall env, wait ..."
# ./uninstall.sh in &> /dev/null

ifcentos=$(cat /proc/version | grep centos)
ifubuntu=$(cat /proc/version | grep ubuntu)

if [ "$ifcentos" != "" ] || [ "$machine" == "i686" ];then
  rpm -e httpd-2.2.3-31.el5.centos gnome-user-share &> /dev/null
fi

if [ -L /etc/rc.local ]; then
  \cp /etc/rc.d/rc.local /etc/rc.d/rc.local.bak
fi
\cp /etc/rc.local /etc/rc.local.bak

if [ "$ifcentos" != "" ];then
  sed -i 's/^exclude/#exclude/' /etc/yum.conf
  yum makecache
  echo "yum remove some ..."
  yum -y remove mysql MySQL-python perl-DBD-MySQL dovecot exim qt-MySQL perl-DBD-MySQL dovecot qt-MySQL \
    mysql-server mysql-connector-odbc php-mysql mysql-bench libdbi-dbd-mysql mysql-devel-5.0.77-3.el5 httpd php \
    mod_auth_mysql mailman squirrelmail php-pdo php-common php-mbstring php-cli
  echo "yum install ..."
  yum -y install gcc gcc-c++ autoconf automake make libtool patch zlib zlib-devel zip unzip \
    ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl libmcrypt libmcrypt-devel libpng libpng-devel \
    libjpeg libjpeg-devel openssl openssl-devel curl curl-devel libxml2 libxml2-devel \
    libaio* gd
  yum -y install pcre pcre-devel libevent libevent-devel
  # Other software: freetype freetype-devel openjpeg openjpeg-devel openjpeg-libs

  # install some system monitor tools, by diwen
  yum -y install tree htop iotop iftop sysstat
  # clean all iptables setting
  # iptables -F
elif [ "$ifubuntu" != "" ];then
  apt-get -y update
  \mv /etc/apache2 /etc/apache2.bak
  \mv /etc/nginx /etc/nginx.bak
  \mv /etc/php5 /etc/php5.bak
  \mv /etc/mysql /etc/mysql.bak
  apt-get -y autoremove apache2 nginx php5 mysql-server
  apt-get -y install unzip build-essential libncurses5-dev libfreetype6-dev libxml2-dev libssl-dev \
    libcurl4-openssl-dev libjpeg62-dev libpng12-dev libfreetype6-dev libsasl2-dev libpcre3-dev autoconf \
    libperl-dev libtool libaio*
  # iptables -F
fi

if [[ ! -x ./env/install_set_sysctl.sh ]]; then
  chmod +x ./env/install_set_sysctl.sh
fi
./env/install_set_sysctl.sh

if [[ ! -x ./env/install_set_ulimit.sh ]]; then
  chmod +x ./env/install_set_ulimit.sh
fi
./env/install_set_ulimit.sh

if [ -e /dev/xvdb ];then
  chmod +x ./env/install_disk.sh
	./env/install_disk.sh
fi

chmod +x ./env/install_dir.sh
./env/install_dir.sh
if [[ "$?" == "1" ]]; then
  echo "./env/install_dir.sh failed"
  exit 1
fi

chmod +x ./env/install_env.sh
./env/install_env.sh

if [[ "$disable_install_mysql" == "false" ]]; then
  chmod +x ./mysql/install_${mysql_dir}.sh
  ./mysql/install_${mysql_dir}.sh
fi

if echo $web | grep "nginx" > /dev/null;then
  chmod +x ./nginx/install_nginx-${nginx_version}.sh
	./nginx/install_nginx-${nginx_version}.sh

  chmod +x ./php/install_nginx_php-${php_version}.sh
	./php/install_nginx_php-${php_version}.sh
  [ "$?" != "0" ] && { echo "./php/install_nginx_php-${php_version}.sh failed !!"; exit 1; }

  chmod +x ./php/install_php_extension.sh
  ./php/install_php_extension.sh
fi

if [[ "$disable_install_mysql" == "false" ]]; then
  echo "init mysql env and password ..."
  /alidata/server/php/bin/php -f ./res/init_mysql.php
  echo "mysql init ok"
fi

if echo $web | grep "nginx" > /dev/null;then
  if ! cat /etc/rc.local | grep "/etc/init.d/nginx" > /dev/null;then
    echo "/etc/init.d/nginx start" >> /etc/rc.local
    echo "/etc/init.d/php-fpm start" >> /etc/rc.local
  fi
fi

if [ "$ifcentos" != "" ] && [ "$machine" == "x86_64" ];then
  sed -i 's/^#exclude/exclude/' /etc/yum.conf
fi

if [ "$ifubuntu" != "" ];then
	mkdir -p /var/lock/subsys/
	sed -i 's#exit 0#touch /var/lock/local#' /etc/rc.local
fi

\cp /etc/profile /etc/profile.bak
if echo $web | grep "nginx" > /dev/null;then
  if [[ "$disable_install_mysql" == "false" ]]; then
    echo 'export PATH=$PATH:/alidata/server/mysql/bin:/alidata/server/nginx/sbin:/alidata/server/php/sbin:/alidata/server/php/bin' >> /etc/profile
    export PATH=$PATH:/alidata/server/mysql/bin:/alidata/server/nginx/sbin:/alidata/server/php/sbin:/alidata/server/php/bin
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/alidata/server/mysql/lib' >> /etc/profile
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/alidata/server/mysql/lib
  else
    echo 'export PATH=$PATH:/alidata/server/nginx/sbin:/alidata/server/php/sbin:/alidata/server/php/bin' >> /etc/profile
    export PATH=$PATH:/alidata/server/nginx/sbin:/alidata/server/php/sbin:/alidata/server/php/bin
  fi
fi

source /etc/profile

# add some other models, by diwen
cd other_mods
if [[ ! -x huakai.sh ]]; then
    chmod a+x huakai.sh
fi
./huakai.sh
if [[ "$?" != "0" ]]; then
  echo "./huakai.sh failed"
  exit 1
fi
cd ..

cd web_api
if [[ ! -x huakai_webapi.sh ]]; then
    chmod a+x huakai_webapi.sh
fi
./huakai_webapi.sh
cd ..

if echo $web | grep "nginx" > /dev/null;then
  /etc/init.d/php-fpm restart

  chown -R huakai:huakai /alidata/server/nginx-1.8.0
  /etc/init.d/nginx restart
  echo "if nginx: [error] open() /var/run/nginx.pid failed, it doesnot matter ~~"

  /etc/init.d/mysqld stop
  /etc/init.d/php-fpm status
  /etc/init.d/mysqld status
  if [[ $(ps -ef | grep nginx|grep -v grep | grep "master process" | wc -l) -eq 1 ]]; then
    echo "nginx is already Running"
  fi
fi

echo "Huakai Base Structure:
Nginx - 1.8.0
PHP   - 5.6.16
Mysql - 5.6.21

Running User      = huakai / huakai123abc!@#
User Dir          = /alidata/huakai
Log  Dir          = /alidata/hk_log - [api/other]
Redis Port        = 6379
CA path           = /alidata/huakai/.ca
Website path      = /alidata/huakai/huakai_api
" >> $install_log

echo "System Env Install OK"
echo "Good Luck !! ^_^"
