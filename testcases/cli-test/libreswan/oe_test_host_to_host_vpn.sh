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
# @Desc      :   Creating a host-to-host VPN
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL libreswan
    systemctl start firewalld
    DNF_INSTALL libreswan 2
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    systemctl enable ipsec --now
    CHECK_RESULT $?
    ipsec initnss
    CHECK_RESULT $?
    firewall-cmd --add-service="ipsec" | grep "success"
    CHECK_RESULT $?
    firewall-cmd --runtime-to-permanent | grep "success"
    CHECK_RESULT $?
    left_ckaid=$(ipsec newhostkey --nssdir /etc/ipsec.d/ 2>&1 | awk '/Generated/{print $7}')
    left_rsa=$(ipsec showhostkey --left --ckaid $left_ckaid --nssdir /etc/ipsec.d/ | grep leftrsasigkey | awk -F "leftrsasigkey=" '{print $2}' | sed 's/^[ \t]*//g')

    P_SSH_CMD --cmd 'systemctl start firewalld;systemctl enable ipsec --now' --node 2
    CHECK_RESULT $?
    P_SSH_CMD --cmd 'firewall-cmd --add-service=\"ipsec\";firewall-cmd --runtime-to-permanent' --node 2
    CHECK_RESULT $?
    P_SSH_CMD --cmd "ipsec newhostkey --nssdir /etc/ipsec.d/ 2>&1 | grep Generated | cut -d ' ' -f 7 >/tmp/key.txt" --node 2
    CHECK_RESULT $?
    SSH_SCP ${NODE2_USER}@${NODE2_IPV4}:/tmp/key.txt /tmp ${NODE2_PASSWORD}
    right_ckaid=$(cat /tmp/key.txt)

    P_SSH_CMD --cmd "ipsec showhostkey --right --ckaid ${right_ckaid} --nssdir /etc/ipsec.d/ | grep rightrsasigkey > /tmp/rsa.txt" --node 2
    CHECK_RESULT $?
    SSH_SCP ${NODE2_USER}@${NODE2_IPV4}:/tmp/rsa.txt /tmp ${NODE2_PASSWORD}
    right_rsa=$(cat /tmp/rsa.txt | awk -F "rightrsasigkey=" '{print $2}' | sed 's/^[ \t]*//g')

    echo -e "conn mytunnel\\n    leftid=@west\\n    left=${NODE1_IPV4}\\n    leftrsasigkey=${left_rsa}\\n    
    rightid=@east\\n    right=${NODE2_IPV4}\\n    rightrsasigkey=${right_rsa}\\n    
    authby=rsasig\\n    auto=start" >/etc/ipsec.d/my_host-to-host.conf
    SSH_SCP /etc/ipsec.d/my_host-to-host.conf ${NODE2_USER}@${NODE2_IPV4}:/etc/ipsec.d/ ${NODE2_PASSWORD}

    ipsec auto --add mytunnel
    CHECK_RESULT $?
    systemctl restart ipsec
    ipsec setup start
    P_SSH_CMD --cmd "ipsec auto --add mytunnel;systemctl restart ipsec;ipsec setup start" --node 2

    ipsec auto --up mytunnel
    CHECK_RESULT $?
    P_SSH_CMD --cmd "ipsec auto --up mytunnel" --node 2
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."

}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop ipsec
    firewall-cmd --remove-service="ipsec"
    firewall-cmd --runtime-to-permanent
    P_SSH_CMD "systemctl stop ipsec;firewall-cmd --remove-service=ipsec;firewall-cmd --runtime-to-permanent" 2
    DNF_REMOVE
    DNF_REMOVE 2 libreswan
    rm -rf /tmp/key.txt /tmp/rsa.txt /etc/ipsec.d/* /var/lib/ipsec/nss/*.db
    P_SSH_CMD "rm -rf /tmp/key.txt /tmp/rsa.txt /etc/ipsec.d/* /var/lib/ipsec/nss/*.db" 2

    LOG_INFO "Finish environment cleanup!"
}

main "$@"
