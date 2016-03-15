#!/bin/bash

if cat /etc/passwd | grep "huakai" > /dev/null; then
    userdel -r -f huakai
    groupdel huakai
fi

mkdir -p /alidata
mkdir -p /alidata/server
mkdir -p /alidata/log
mkdir -p /alidata/log/php
mkdir -p /alidata/log/mysql
mkdir -p /alidata/log/nginx
#mkdir -p /alidata/log/nginx/access

# here, add the nologin user for huakai
# if [ "$ifcentos" != "" ];then
#     useradd -g huakai -M -d /alidata/huakai -s /sbin/nologin huakai &> /dev/null
# elif [ "$ifubuntu" != "" ];then
#     useradd -g huakai -M -d /alidata/huakai -s /usr/sbin/nologin huakai &> /dev/null
# fi

groupadd huakai
useradd -g huakai -d /alidata/huakai huakai > /dev/null
sleep 1
echo -e "huakai123abc\0041@#" | passwd --stdin huakai

# add sudo no passwd permission for huakai user
echo "%huakai ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# check huakai user
if [[ $(cat /etc/passwd | grep huakai | wc -l) -eq 1 ]]; then
    echo "Create huakai user successfully."
else
    echo "Create huakai user failed !!!"
    echo "quit !"
    exit 1
fi

# Create the server log dir
chown -R huakai:huakai /alidata/log

if [[ "$disable_install_mysql" == "false" ]]; then
    mkdir -p /alidata/server/${mysql_dir}
    ln -s /alidata/server/${mysql_dir} /alidata/server/mysql
fi

mkdir -p /alidata/server/${php_dir}
ln -s /alidata/server/${php_dir} /alidata/server/php

mkdir -p /alidata/server/${web_dir}
if echo $web | grep "nginx" > /dev/null;then
    mkdir -p /alidata/log/nginx
    #mkdir -p /alidata/log/nginx/access
    ln -s /alidata/server/${web_dir} /alidata/server/nginx
fi

# Create log dir for huakai web api and other maintain python
mkdir -p /alidata/hk_log/api
mkdir -p /alidata/hk_log/other/pylog
chown huakai.huakai -R /alidata/hk_log
chmod 0766 -R /alidata/hk_log/other

echo "install dir ok"
