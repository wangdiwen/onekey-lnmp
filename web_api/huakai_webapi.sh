#!/bin/bash

cat << HELP

Note this:

  Config the Huakai Website HTTPS API.
  CA path      = /alidata/.ca
  Website path = /alidata/huakai_api

HELP

echo "copy ca and nginx - huakai_api vhosts file ..."

mkdir -p /alidata/.ca
\cp ./ca/huakai.key /alidata/.ca
\cp ./ca/huakai.crt /alidata/.ca
chmod 0444 -R /alidata/.ca

\cp ./*.conf /alidata/server/nginx/conf/vhosts

echo "sync the huakai_api Website code repo ..."
if [[ ! -d /alidata/huakai/huakai_api ]]; then
    mkdir /alidata/huakai/huakai_api
    mkdir /alidata/huakai/py-huakai

    mkdir /alidata/huakai/dokuwiki
    mkdir /alidata/huakai/download

    chown -R huakai:huakai /alidata/huakai
fi

echo "modify the nginx welcome web page ..."
echo "just for https://huakai.com/ URL"
if [[ ! -d "/alidata/server/nginx/html" ]]; then
    mkdir -p /alidata/server/nginx/html
fi
\cp -f ./index.html /alidata/server/nginx/html/
\cp -f ./50x.html /alidata/server/nginx/html/
\cp -f ./404.html /alidata/server/nginx/html/

echo "install huakai webapi ok"
