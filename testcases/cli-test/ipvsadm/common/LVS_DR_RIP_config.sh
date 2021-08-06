#!/usr/bin/bash
RIP=$(ip addr show | grep inet | grep -v inet6 | grep -Ewv "lo.*|docker.*|bond.*|vlan.*|virbr.*|br-.*" | awk '{print $2}' | awk -F "/" '{print $1}' | head -1)
DEV=$(ip addr show | grep inet | grep -v inet6 | grep -Ewv "lo.*|docker.*|bond.*|vlan.*|virbr.*|br-.*" | awk '{print $NF}' | head -1)
VIP=$(echo $RIP | cut -d '.' -f 1-3).100
. /etc/rc.d/init.d/functions
case "$1" in
start)
    echo "reparing for Real Server"
    echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
    echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
    echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
    echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
    dnf -y install httpd
    systemctl start httpd
    systemctl stop firewalld
    ip addr add $VIP/22 dev $DEV
    server1=server$RIP
    echo "$server1" >/var/www/html/index.html
    check_http=$(curl localhost)
    echo $check_http
    if [ ${check_http} == $server1 ]; then
        echo "RS server1 environment is ready."
    else
        echo "RS server1 curl localhost is  error."
    fi
    ;;
stop)
    ip addr del $VIP/22 dev $DEV
    echo "0" >/proc/sys/net/ipv4/conf/lo/arp_ignore
    echo "0" >/proc/sys/net/ipv4/conf/lo/arp_announce
    echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
    echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce
    rm -rf /var/www/html/index.html /tmp/LVS_DR_RIP_config.sh
    dnf -y remove httpd
    systemctl start firewalld
    systemctl stop httpd
    ;;
*)
    echo "Usage: LVS_DR_RIP_config.sh {start|stop}"
    exit 1
    ;;
esac
