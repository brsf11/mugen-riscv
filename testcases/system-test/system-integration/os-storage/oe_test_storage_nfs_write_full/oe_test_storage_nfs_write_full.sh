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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-4-10
# @License   :   Mulan PSL v2
# @Desc      :   Read write when NFS share is full
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    remote_disk=$(lsblk | grep disk | sed -n 2p | awk '{print$1}')
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL nfs-utils
    systemctl stop firewalld
    iptables -F
    SSH_CMD "systemctl stop firewalld;iptables -F" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    SSH_CMD "yum install nfs-utils -y;mkdir /home/nfs;mv /etc/exports /etc/exports.bak;
	echo '/home/nfs *(rw,sync,all_squash)' >/etc/exports; exportfs -avr" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    SSH_CMD "systemctl restart nfs-server rpcbind;mkfs.ext4 -F /dev/${remote_disk};
	mount /dev/${remote_disk} /home/nfs;chmod -R 777 /home/nfs" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    mkdir /home/client
    chmod 777 -R /home/client
    systemctl restart nfs-server rpcbind
    mount -t nfs ${NODE2_IPV4}:/home/nfs /home/client
    CHECK_RESULT $?
    df -h | grep ${NODE2_IPV4}
    CHECK_RESULT $?
    SSH_CMD "dd if=/dev/zero of=/home/nfs/test bs=1k count=1" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    dd if=/dev/zero of=/home/client/test1 bs=1M count=1
    CHECK_RESULT $? 
    SSH_CMD "rm -rf /home/nfs/*" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SLEEP_WAIT 2
    dd if=/dev/zero of=/home/client/test1 bs=1M count=1
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /home/client
    SLEEP_WAIT 2
    SSH_CMD "umount /home/nfs;rm -rf /home/nfs;yum remove -y nfs-utils;mv -f /etc/exports.bak /etc/exports;
    umount /home/nfs; systemctl start firewalld" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    rmdir /home/client
    systemctl start firewalld
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
