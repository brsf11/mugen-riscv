#!/usr/bin/bash
NODE1_IPV4=$(ip addr show | grep inet | grep -v inet6 | grep -Ewv "lo.*|docker.*|bond.*|vlan.*|virbr.*|br-.*" | awk '{print $2}' | awk -F "/" '{print $1}' | head -1)
VIP=$(echo ${NODE1_IPV4} | cut -d '.' -f 1-3).100
DEV=$(ip addr show | grep inet | grep -v inet6 | grep -Ewv "lo.*|docker.*|bond.*|vlan.*|virbr.*|br-.*" | awk '{print $NF}' | head -1)
. /etc/rc.d/init.d/functions
case "$1" in
start)
  echo "reparing for Real Server"
  ip addr add $VIP/22 dev $DEV
  dnf -y install ipvsadm
  ipvsadm
  ipvsadm -C
  ipvsadm -A -t $VIP:80 -s rr
  ipvsadm -a -t $VIP:80 -r ${NODE1_IPV4}:80 -g
  ipvsadm
  ipvsadm-save -n >/etc/sysconfig/ipvsadm
  ipvsadm -C
  ipvsadm -R </etc/sysconfig/ipvsadm
  sleep 5
  ipvsadm >>/tmp/ipvsadm_restore.txt

  ;;
stop)
  ipvsadm -C
  ip addr del $VIP/22 dev $DEV
  rm -rf /tmp/ipvsadm* /tmp/SAVE_RESROER.sh
  dnf -y remove ipvsadm
  ;;
*)
  echo "Usage: LVS_DR_RIP_config.sh {start|stop}"
  exit 1
  ;;
esac
