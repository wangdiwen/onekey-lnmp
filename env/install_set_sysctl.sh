#!/bin/bash

\cp /etc/sysctl.conf /etc/sysctl.conf.bak
sed -i 's/net\.ipv4\.tcp_syncookies.*/net\.ipv4\.tcp_syncookies = 1/' /etc/sysctl.conf

if cat /etc/sysctl.conf | grep "aliyun web add" > /dev/null ;then
echo ""
else
cat >> /etc/sysctl.conf <<EOF

#aliyun web add
fs.file-max=65535
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 5
net.ipv4.tcp_syn_retries = 5
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 60
net.ipv4.ip_local_port_range = 1024  65535
net.ipv4.tcp_window_scaling = 0
net.ipv4.tcp_sack = 0
kernel.shmall = 2097152
kernel.shmmax = 2147483648
kernel.shmmni = 4096
kernel.sem = 5010 641280 5010 128
kernel.hung_task_timeout_secs = 0
net.core.wmem_default=262144
net.core.wmem_max=262144
net.core.rmem_default=4194304
net.core.rmem_max=4194304
EOF
fi
sysctl -p

echo "install set sysctl ok"
