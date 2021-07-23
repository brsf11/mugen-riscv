#!/usr/bin/bash
# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/10/12
# @License   :   Mulan PSL v2
# @Desc      :   Public class integration
#####################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function deploy_env() {
    DNF_INSTALL "ndisc6 xinetd time"
    hostname_init=$(hostname)
    hostname newlocalhost
    NODE1_IPV6=$(ip addr show ${NODE1_NIC[0]} | grep -w inet6 | awk '{print $2}' | awk -F '/' '{print $1}' | awk 'NR==1{print $1}')
    NODE2_IPV6=$(P_SSH_CMD --node 2 --cmd "ip addr show ${NODE2_NIC[0]}" | grep -w inet6 | awk '{print $2}' | awk -F '/' '{print $1}' | awk 'NR==1{print $1}')
    cp /etc/resolv.conf /etc/resolv.conf-bak
    sed -i 's/name/#&/' /etc/resolv.conf
    sed -i '6s/yes/no/g' /etc/xinetd.d/echo-stream
    systemctl restart xinetd
    DNF_INSTALL xinetd 2
    P_SSH_CMD --node 2 --cmd "sed -i '6s/yes/no/g' /etc/xinetd.d/echo-stream;systemctl restart xinetd;"
}

function clear_env() {
    DNF_REMOVE
    hostname ${hostname_init}
    cp -rf /etc/resolv.conf-bak /etc/resolv.conf
    rm -rf file runtime /etc/resolv.conf-bak
}
