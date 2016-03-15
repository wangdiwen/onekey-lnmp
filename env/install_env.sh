#!/bin/sh

cd env

CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)

# download some soft
\rm -f *.gz *.bz2
if [[ $open_download_137 -eq 1 ]]; then
    wget http://115.29.97.137:8181/libiconv-1.13.1.tar.gz
    wget http://115.29.97.137:8181/zlib-1.2.3.tar.gz
    wget http://115.29.97.137:8181/freetype-2.1.10.tar.gz
    wget http://115.29.97.137:8181/libpng-1.2.53.tar.gz
    wget http://115.29.97.137:8181/libevent-1.4.14b.tar.gz
    wget http://115.29.97.137:8181/libmcrypt-2.5.8.tar.gz
    wget http://115.29.97.137:8181/jpegsrc.v9a.tar.gz
    wget http://115.29.97.137:8181/pcre-8.37.tar.bz2
fi

# note: libiconv use 1.13 version
if [ ! -f libiconv-1.13.1.tar.gz ];then
	wget http://oss.aliyuncs.com/aliyunecs/onekey/libiconv-1.13.1.tar.gz
fi
rm -rf libiconv-1.13.1
tar zxvf libiconv-1.13.1.tar.gz
cd libiconv-1.13.1
./configure --prefix=/usr/local
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
cd ..

if [[ $(which rpm | wc -l) -eq 1 ]] && [[ $(rpm -qa | grep zlib | wc -l) -eq 0 ]]; then
    if [ ! -f zlib-1.2.3.tar.gz ];then
        wget http://oss.aliyuncs.com/aliyunecs/onekey/zlib-1.2.3.tar.gz
    fi
    rm -rf zlib-1.2.3
    tar zxvf zlib-1.2.3.tar.gz
    cd zlib-1.2.3
    ./configure
    if [ $CPU_NUM -gt 1 ];then
        make CFLAGS=-fpic -j$CPU_NUM
    else
        make CFLAGS=-fpic
    fi
    make install
    cd ..
fi

if [ ! -f freetype-2.1.10.tar.gz ];then
	wget http://oss.aliyuncs.com/aliyunecs/onekey/freetype-2.1.10.tar.gz
fi
rm -rf freetype-2.1.10
tar zxvf freetype-2.1.10.tar.gz
cd freetype-2.1.10
./configure --prefix=/usr/local/freetype.2.1.10
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
cd ..

if [ ! -f libpng-1.2.53.tar.gz ];then
    wget http://oss.aliyuncs.com/aliyunecs/onekey/libpng-1.2.53.tar.gz
fi
rm -rf libpng-1.2.53
tar zxvf libpng-1.2.53.tar.gz
cd libpng-1.2.53
./configure --prefix=/usr/local/libpng.1.2.53
if [ $CPU_NUM -gt 1 ];then
    make CFLAGS=-fpic -j$CPU_NUM
else
    make CFLAGS=-fpic
fi
make install
cd ..

if [[ $(rpm -q libevent | grep "not" | wc -l) -eq 1 ]]; then
    if [ ! -f libevent-1.4.14b.tar.gz ];then
        wget http://oss.aliyuncs.com/aliyunecs/onekey/libevent-1.4.14b.tar.gz
    fi
    rm -rf libevent-1.4.14b
    tar zxvf libevent-1.4.14b.tar.gz
    cd libevent-1.4.14b
    ./configure
    if [ $CPU_NUM -gt 1 ];then
        make -j$CPU_NUM
    else
        make
    fi
    make install
    cd ..
fi

if [[ $(rpm -q libmcrypt | grep "not" | wc -l) -eq 1 ]]; then
    if [ ! -f libmcrypt-2.5.8.tar.gz ];then
        wget http://oss.aliyuncs.com/aliyunecs/onekey/libmcrypt-2.5.8.tar.gz
    fi
    rm -rf libmcrypt-2.5.8
    tar zxvf libmcrypt-2.5.8.tar.gz
    cd libmcrypt-2.5.8
    ./configure --disable-posix-threads
    if [ $CPU_NUM -gt 1 ];then
        make -j$CPU_NUM
    else
        make
    fi
    make install
    /sbin/ldconfig
    cd libltdl/
    ./configure --enable-ltdl-install
    make
    make install
    cd ../..
fi

if [[ $(rpm -q pcre | grep "not" | wc -l) -eq 1 ]] || [[ $(rpm -q pcre-devel | grep "not" | wc -l) -eq 1 ]] ; then
    if [ ! -f pcre-8.37.tar.bz2 ];then
        # wget http://oss.aliyuncs.com/aliyunecs/onekey/pcre-8.37.tar.gz  -- not support
        wget http://nchc.dl.sourceforge.net/project/pcre/pcre/8.37/pcre-8.37.tar.bz2
    fi
    rm -rf pcre-8.37
    tar jxvf pcre-8.37.tar.bz2
    cd pcre-8.37
    ./configure
    if [ $CPU_NUM -gt 1 ];then
        make -j$CPU_NUM
    else
        make
    fi
    make install
    cd ..
fi

if [ ! -f jpegsrc.v9a.tar.gz ];then
	# wget http://oss.aliyuncs.com/aliyunecs/onekey/jpegsrc.v9a.tar.gz  -- not support
    wget http://www.ijg.org/files/jpegsrc.v9a.tar.gz
fi
rm -rf jpeg-9a
tar zxvf jpegsrc.v9a.tar.gz
cd jpeg-9a
if [ -e /usr/share/libtool/config.guess ];then
    cp -f /usr/share/libtool/config.guess .
elif [ -e /usr/share/libtool/config/config.guess ];then
    cp -f /usr/share/libtool/config/config.guess .
fi
if [ -e /usr/share/libtool/config.sub ];then
    cp -f /usr/share/libtool/config.sub .
elif [ -e /usr/share/libtool/config/config.sub ];then
    cp -f /usr/share/libtool/config/config.sub .
fi
./configure --prefix=/usr/local/jpeg.6 --enable-shared --enable-static
mkdir -p /usr/local/jpeg.6/include
mkdir /usr/local/jpeg.6/lib
mkdir /usr/local/jpeg.6/bin
mkdir -p /usr/local/jpeg.6/man/man1
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install-lib
make install
cd ..

touch /etc/ld.so.conf.d/usrlib.conf
echo "/usr/local/lib" >> /etc/ld.so.conf.d/usrlib.conf
echo "/usr/local/jpeg.6/lib" >> /etc/ld.so.conf.d/usrlib.conf
echo "/usr/local/freetype.2.1.10/lib" >> /etc/ld.so.conf.d/usrlib.conf
echo "/usr/local/libpng.1.2.50/lib" >> /etc/ld.so.conf.d/usrlib.conf
/sbin/ldconfig

cd ..
echo "install env ok"
