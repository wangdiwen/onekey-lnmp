#!/bin/bash

cat << HELP
	Create the CA signification for Huakai Website.
	...
HELP

echo "check the openssl soft ..."
num=$(rpm -qa | grep openssl | wc -l)
if [[ $num -ne 2 ]]; then
   yum -y install openssl openssl-devel
fi

echo "reset all .sh script permission .."
# find . -name "*.sh" | xargs chmod a+x

echo '++++++++++++++++++ check existed CA +++++++++++++++++'
if [[ -f ./web_api/ca/huakai.key.passwd ]]; then
    echo 'Already has, quit!'
    exit 0
fi

echo "backup old CA ..."
if [[ -d ./web_api/ca ]]; then
    if [ -d ./web_api/ca.bak ]; then
        \rm -rf ./web_api/ca.bak
    fi
    \mv ./web_api/ca ./web_api/ca.bak
fi

mkdir ./web_api/ca
cd ./web_api/ca
echo " ----- Create the CA ------------------------"
echo " ----- tips: input the pass phrase -> huakai"
echo " ----- tips: the Common name       -> domain like: api.jianyueyun.com"
echo " ----- tips: the passwd            -> huakai123abc!@#"
echo " ----- tips: the email             -> dw_wang126@126.com"
echo
echo "create private key ..."
openssl genrsa -des3 -out huakai.key 1024
echo
echo

echo "create CSR file ..."
openssl req -new -key huakai.key -out huakai.csr

echo
echo "disable the private key passwd ..."
\cp huakai.key huakai.key.passwd
\cp huakai.key.passwd huakai.key.org
\rm huakai.key
openssl rsa -in huakai.key.org -out huakai.key

echo
echo "produce the CRT signification file ..."
openssl x509 -req -days 30000 -in huakai.csr -signkey huakai.key -out huakai.crt

if [[ -d "/alidata/.ca" ]]; then
	\rm -rf /alidata/.ca
fi

# end of web_api/ca dir
cd ../..

echo
echo "create CA ok"
echo "The CRT certificate            : web_api/ca/huakai.crt"
echo "The private Key(no passwd)     : web_api/ca/huakai.key"
echo ""
