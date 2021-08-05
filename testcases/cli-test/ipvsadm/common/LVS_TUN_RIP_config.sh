#!/usr/bin/bash
RIP=$(ip addr show | grep inet | grep -v inet6 | grep -Ewv "lo.*|docker.*|bond.*|vlan.*|virbr.*|br-.*" | awk '{print $2}' | awk -F "/" '{print $1}' | head -1)
DEV=$(ip addr show | grep inet | grep -v inet6 | grep -Ewv "lo.*|docker.*|bond.*|vlan.*|virbr.*|br-.*" | awk '{print $NF}' | head -1)
VIP=$(echo $RIP | cut -d '.' -f 1-3).100
. /etc/rc.d/init.d/functions
case "$1" in
start)
    echo "reparing for Real Server"
    dnf -y install httpd net-tools 
    systemctl start httpd
    systemctl stop firewalld
    ifconfig tunl0 $VIP netmask 255.255.255.255 broadcast $VIP up
    route add -host $VIP dev tunl0
    sleep 5
    sysctl -a | grep rp_filter
    sleep 5
    sysctl -w net.ipv4.conf.all.rp_filter=0
    sysctl -w net.ipv4.conf.default.rp_filter=0
    sysctl -w net.ipv4.conf.$DEV.rp_filter=0
    sysctl -w net.ipv4.conf.tunl0.rp_filter=0
    server1=server$RIP
    echo "$server1" >/var/www/html/index.html
    check_http=$(curl localhost)
    if [ ${check_http} == $server1 ]; then
        echo "RS server1 environment is ready."
    else
        echo "RS server1 curl localhost is  error."
    fi
    ;;
stop)
    route del -host $VIP dev tunl0
    ifconfig tunl0 $VIP broadcast $VIP netmask 255.255.255.255 down
    sleep 5
    sysctl -a | grep rp_filter
    sleep 10
    sysctl -w net.ipv4.conf.all.rp_filter=1
    sysctl -w net.ipv4.conf.default.rp_filter=1
    sysctl -w net.ipv4.conf.$DEV.rp_filter=1
    sysctl -w net.ipv4.conf.tunl0.rp_filter=1
    sleep 2
    rm -rf /var/www/html/index.html /tmp/LVS_TUN_RIP_config.sh
    dnf -y remove httpd remove net-tools
    systemctl start firewalld
    systemctl stop httpd
    ;;
*)
    echo "Usage: LVS_DR_RIP_config.sh {start|stop}"
    exit 1
    ;;
esac
