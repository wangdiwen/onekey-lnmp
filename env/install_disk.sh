#!/bin/bash

# Note: this script just for format the extra /dev/xvdb disk.
mkdir -p /alidata

if which mkfs.ext4 > /dev/null ;then
	# xvdb1 is a partion already
	if ls /dev/xvdb1 > /dev/null;then
	   if cat /etc/fstab | grep /alidata > /dev/null ;then
			if cat /etc/fstab|grep /alidata|grep ext3 > /dev/null ;then
				sed -i "/\/alidata/d" /etc/fstab
				echo '/dev/xvdb1  /alidata  ext4  defaults  0 0' >> /etc/fstab
			fi
	   else
			echo '/dev/xvdb1  /alidata  ext4  defaults  0 0' >> /etc/fstab
	   fi
	   mount -a
	   echo ""
	   exit
	else
		# xvdb not format
		if ls /dev/xvdb > /dev/null ;then
fdisk /dev/xvdb << EOF
n
p
1


wq
EOF
			mkfs.ext4 /dev/xvdb1
			echo '/dev/xvdb1  /alidata  ext4  defaults  0 0' >> /etc/fstab
		fi
	fi
else
	echo "not find mkfs.ext4 tool, quit !!\n"
	exit 1
fi

mount -a
echo "install disk ok\n"
