#!/usr/bin/bash
NODE1_IPV4=$(ip addr show | grep inet | grep -v inet6 | grep -Ewv "lo.*|docker.*|bond.*|vlan.*|virbr.*|br-.*" | awk '{print $2}' | awk -F "/" '{print $1}' | head -1)
VIP=$(echo ${NODE1_IPV4} | cut -d '.' -f 1-3).100
for i in {1..6}; do
   curl $VIP >>/tmp/result_curl.txt
done
