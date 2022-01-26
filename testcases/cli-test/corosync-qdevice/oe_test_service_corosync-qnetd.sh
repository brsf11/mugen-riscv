#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   wenjun
# @Contact   :   1009065695@qq.com
# @Date      :   2021/12/30
# @License   :   Mulan PSL v2
# @Desc      :   Test corosync-qnetd.service restart
# #############################################

source "../common/ha.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    service=corosync-qnetd.service
    ha_pre
    DNF_INSTALL "corosync-qdevice corosync-qnetd"
    P_SSH_CMD --node 2 --cmd "dnf install -y corosync-qdevice corosync-qnetd"
    P_SSH_CMD --node 3 --cmd "mv /etc/hosts /etc/hosts_bak"
    echo "${NODE3_IPV4} qdevice" >> /etc/hosts    
    SSH_SCP /etc/hosts ${NODE2_USER}@${NODE2_IPV4}:/etc/ "${NODE2_PASSWORD}"
    SSH_SCP /etc/hosts ${NODE3_USER}@${NODE3_IPV4}:/etc/ "${NODE3_PASSWORD}"
    P_SSH_CMD --node 3 --cmd "dnf install -y corosync pacemaker pcs corosync-qdevice corosync-qnetd;
    systemctl start pcsd;
    hostnamectl set-hostname qdevice;
    systemctl stop firewalld;
    systemctl disable firewalld;
    echo "${NODE1_PASSWORD}" | passwd --stdin hacluster;
    pcs qdevice setup model net --enable --start" 
    pcs host auth qdevice < /root/hacluster
    pcs quorum device add model net host=qdevice algorithm=ffsplit
    corosync-qnetd-certutil -i
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution "${service}"
    test_reload "${service}"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop "${service}"
    pcs quorum device remove model net host=qdevice
    P_SSH_CMD --node 3 --cmd "pcs qdevice destroy net;
    systemctl stop pcsd;
    hostnamectl set-hostname ${hostname};
    systemctl start firewalld;
    systemctl enable firewalld;
    dnf remove -y corosync pacemaker pcs corosync-qdevice corosync-qnetd;
    mv /etc/hosts_bak /etc/hosts"
    DNF_REMOVE
    P_SSH_CMD --node 2 --cmd "dnf remove -y corosync-qdevice corosync-qnetd"
    ha_post
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
