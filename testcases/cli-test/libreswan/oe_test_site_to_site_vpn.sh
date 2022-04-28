#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @modify    :   wangxiaoya@qq.com
# @Date      :   2022/05/06
# @License   :   Mulan PSL v2
# @Desc      :   Configuring a site-to-site VPN
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "libreswan net-tools"
    DNF_INSTALL "libreswan net-tools" 2
    systemctl start firewalld
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    systemctl enable ipsec --now
    CHECK_RESULT $?
    firewall-cmd --add-service="ipsec" | grep "success"
    CHECK_RESULT $?
    firewall-cmd --runtime-to-permanent | grep "success"
    CHECK_RESULT $?
    left_ckaid=$(ipsec newhostkey --nssdir /etc/ipsec.d/ 2>&1 | awk '/Generated/{print $7}')
    left_mask=$(ifconfig ${NODE1_NIC} | grep netmask | tr -s " " | awk '{print $4}')
    left6_mask=$(ip -6 route show dev ${NODE1_NIC} | head -n 1 | awk '{print $1}')
    left_rsa=$(ipsec showhostkey --left --ckaid $left_ckaid --nssdir /etc/ipsec.d/ | grep leftrsasigkey | awk -F "leftrsasigkey=" '{print $2}' | sed 's/^[ \t]*//g')
    
    P_SSH_CMD --cmd  "systemctl start firewalld;systemctl enable ipsec --now" --node 2
    CHECK_RESULT $?
    P_SSH_CMD --cmd  'firewall-cmd --add-service=\"ipsec\";firewall-cmd --runtime-to-permanent' --node 2
    CHECK_RESULT $?
    P_SSH_CMD --cmd  "ipsec newhostkey --nssdir /etc/ipsec.d/ 2>&1 | grep Generated | cut -d ' ' -f 7 >/tmp/key.txt" --node 2
    SSH_SCP ${NODE2_USER}@${NODE2_IPV4}:/tmp/key.txt /tmp ${NODE2_PASSWORD}
    right_ckaid=$(cat /tmp/key.txt)

    P_SSH_CMD --cmd  "ipsec showhostkey --right --ckaid ${right_ckaid} --nssdir /etc/ipsec.d/  | grep rightrsasigkey > /tmp/rsa.txt" --node 2
    CHECK_RESULT $?
    SSH_SCP ${NODE2_USER}@${NODE2_IPV4}:/tmp/rsa.txt /tmp ${NODE2_PASSWORD}
    right_rsa=$(cat /tmp/rsa.txt | awk -F "rightrsasigkey=" '{print $2}' | sed 's/^[ \t]*//g')
 
    P_SSH_CMD --cmd  "ifconfig ${NODE2_NIC} | grep netmask >/tmp/right_mask.txt" --node 2
    CHECK_RESULT $?
    SSH_SCP ${NODE2_USER}@${NODE2_IPV4}:/tmp/right_mask.txt /tmp ${NODE2_PASSWORD}
    P_SSH_CMD --cmd  "ip -6 route show dev ${NODE1_NIC}>/tmp/right6_mask.txt" --node 2
    CHECK_RESULT $?
    SSH_SCP ${NODE2_USER}@${NODE2_IPV4}:/tmp/right6_mask.txt /tmp ${NODE2_PASSWORD}
    right_mask=$(cat /tmp/right_mask.txt | awk '{print $4}')
    right6_mask=$(cat /tmp/right6_mask.txt | awk '{print $1}')
 
    echo -e "conn mysubnet\\n     also=mytunnel\\n     leftsubnet=${left_mask}/24\\n     rightsubnet=${right_mask}/24\\n     
    auto=start\\n\\nconn mysubnet6\\n     also=mytunnel\\n     leftsubnet=${left6_mask}\\n     rightsubnet=${right6_mask}\\n     
    auto=start\\n\\n\\nconn mytunnel\\n    leftid=@west\\n    left=${NODE1_IPV4}\\n    leftrsasigkey=${left_rsa}\\n    
    rightid=@east\\n    right=${NODE2_IPV4}\\n    rightrsasigkey=${right_rsa}\\n    authby=rsasig" >/etc/ipsec.d/my_site-to-site.conf
    SSH_SCP /etc/ipsec.d/my_site-to-site.conf ${NODE2_USER}@${NODE2_IPV4}:/etc/ipsec.d/ ${NODE2_PASSWORD}
    ipsec auto --add mysubnet
    CHECK_RESULT $? 0 0 "add mysubnet failed"
    systemctl restart ipsec
    ipsec setup start
    P_SSH_CMD --cmd "ipsec auto --add mysubnet;systemctl restart ipsec;ipsec setup start" --node 2

    ipsec auto --up mysubnet
    CHECK_RESULT $? 0 0 "up mysubnet failed"
    P_SSH_CMD --cmd  "ipsec auto --up mysubnet" --node 2
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop ipsec
    firewall-cmd --remove-service="ipsec"
    firewall-cmd --runtime-to-permanent
    P_SSH_CMD --cmd  "systemctl stop ipsec;firewall-cmd --remove-service=ipsec;firewall-cmd --runtime-to-permanent" --node 2
    DNF_REMOVE
    DNF_REMOVE 2 "net-tools libreswan"
    rm -rf /tmp/*.txt /etc/ipsec.d/* /var/lib/ipsec/nss/*.db
    P_SSH_CMD --cmd  "rm -rf /tmp/*.txt /etc/ipsec.d/* /var/lib/ipsec/nss/*.db" --node 2
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
