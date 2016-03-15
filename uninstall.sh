#!/bin/bash

if [ "$1" != "in" ];then
	echo "Before cleaning the installation script environment,"
	echo "Please backup your data !!"
	read -p "Enter the y or Y to continue:" is_y
	if [ "${is_y}" != "y" ] && [ "${is_y}" != "Y" ];then
	   exit 1
	fi
fi

mkdir -p /alidata
if which mkfs.ext4 > /dev/null;then
	if ls /dev/xvdb1 &> /dev/null;then
	   if cat /etc/fstab | grep /alidata > /dev/null ;then
			if cat /etc/fstab | grep /alidata | grep ext3 > /dev/null ;then
				sed -i "/\/alidata/d" /etc/fstab
			fi
	   else
			echo '/dev/xvdb1  /alidata  ext4  defaults  0 0' >> /etc/fstab
	   fi
	   mount -a
	fi
else
	echo "not find mkfs.ext4 tool, quit !!\n"
	exit 1
fi

echo "stop service ..."
/etc/init.d/nginx stop
sleep 2
/etc/init.d/php-fpm stop
sleep 3
/etc/init.d/mysqld stop
sleep 2
# killall nginx
# killall php-fpm
# killall mysqld

echo "clean some /usr/local libs ..."
rm -rf /usr/local/freetype.2.1.10
rm -rf /usr/local/libpng.1.2.50
rm -rf /usr/local/freetype.2.1.10
rm -rf /usr/local/libpng.1.2.50
rm -rf /usr/local/jpeg.6

echo "clean libmemcached ..."
\rm -rf /usr/local/libmemcached

echo "/alidata/server/mysql             delete ok!"
rm -rf /alidata/server/mysql
echo "rm -rf /alidata/server/mysql-*    delete ok!"
rm -rf /alidata/server/mysql-*
echo "/alidata/server/php               delete ok!"
rm -rf /alidata/server/php
echo "/alidata/server/php-*             delete ok!"
rm -rf /alidata/server/php-*
echo "/alidata/server/nginx             delete ok!"
rm -rf /alidata/server/nginx
echo "rm -rf /alidata/server/nginx-*    delete ok!"
rm -rf /alidata/server/nginx-*

echo ""
echo "/alidata/log/php                  delete ok!"
rm -rf /alidata/log/php
echo "/alidata/log/mysql                delete ok!"
rm -rf /alidata/log/mysql
echo "/alidata/log/nginx                delete ok!"
rm -rf /alidata/log/nginx

echo ""
echo "/etc/my.cnf                delete ok!"
rm -f /etc/my.cnf
echo "/etc/init.d/mysqld         delete ok!"
rm -f /etc/init.d/mysqld
echo "/etc/init.d/nginx          delete ok!"
rm -f /etc/init.d/nginx
echo "/etc/init.d/php-fpm        delete ok!"
rm -r /etc/init.d/php-fpm

echo ""
ifrpm=$(cat /proc/version | grep -E "redhat|centos")
ifdpkg=$(cat /proc/version | grep -Ei "ubuntu|debian")
ifcentos=$(cat /proc/version | grep centos)

echo "/etc/rc.local                   clean ok!"
if [ "$ifrpm" != "" ];then
	# centos system, rc.local is a link
	if [ -L /etc/rc.local ];then
		echo ""
	else
		\cp /etc/rc.local /etc/rc.local.bak
		rm -rf /etc/rc.local
		ln -s /etc/rc.d/rc.local /etc/rc.local
	fi

	sed -i "/\/etc\/init\.d\/nginx.*/d" /etc/rc.d/rc.local
	sed -i "/\/etc\/init\.d\/php-fpm.*/d" /etc/rc.d/rc.local
	sed -i "/\/etc\/init\.d\/redis.*/d" /etc/rc.d/rc.local
else
	# ubuntu system, rc.local is a file
	sed -i "/\/etc\/init\.d\/nginx.*/d" /etc/rc.local
	sed -i "/\/etc\/init\.d\/php-fpm.*/d" /etc/rc.local
	sed -i "/\/etc\/init\.d\/redis.*/d" /etc/rc.local
fi

echo ""
echo "/etc/profile                    clean ok!"
sed -i "/export PATH=\$PATH\:\/alidata\/server\/mysql\/bin.*/d" /etc/profile
sed -i "/export PATH=\$PATH\:\/alidata\/server\/nginx\/sbin.*/d" /etc/profile
sed -i "/export PATH=\$PATH\:\/alidata\/server\/redis\/bin/d" /etc/profile
sed -i "/export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH\:\/alidata\/server.*/d" /etc/profile
source /etc/profile

echo ""
echo "clean /etc/sudoers ... ok!"
sed -i '/%huakai ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers

echo "delete user huakai ..."
userdel -r -f huakai
groupdel huakai

echo "delete mysql user ..."
userdel -r -f mysql
groupdel mysql

echo "stop the redis server ..."
/etc/init.d/redis stop
echo "delete redis config files ..."
\rm -f /etc/init.d/redis
\rm -rf /alidata/server/redis/

echo
echo "delete the alidata/ all data ..."
if [[ -f /alidata/install-info.log ]]; then
	rm -f /alidata/install-info.log
fi

\rm -rf /alidata/server /alidata/log /alidata/hk_log

if [[ -d /alidata/huakai ]]; then
	\rm -rf /alidata/huakai
fi
if [[ -d /alidata/.ca ]]; then
	\rm -rf /alidata/.ca
fi

echo "Uninstall 					OK !"
