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
# @Date      :   2020-5-8
# @License   :   Mulan PSL v2
# @Desc      :   NFS restart server
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "nfs-utils dmidecode"
    systemctl stop firewalld
    iptables -F
    SSH_CMD "systemctl stop firewalld;iptables -F" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    SSH_CMD "yum install nfs-utils -y;mkdir /home/nfs;touch /home/nfs/testnfs;chmod -R 777 /home/nfs;
    mv /etc/exports /etc/exports.bak;echo '/home/nfs *(rw,sync,all_squash)' >/etc/exports" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "exportfs -avr" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    SSH_CMD "systemctl enable nfs-server rpcbind;systemctl restart nfs-server rpcbind" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}

    SLEEP_WAIT 3
    mount -t nfs ${NODE2_IPV4}:/home/nfs /mnt
    CHECK_RESULT $?
    df -h | grep ${NODE2_IPV4}
    CHECK_RESULT $?
    test -f /mnt/testnfs
    CHECK_RESULT $?

    SSH_CMD "reboot" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}

    SLEEP_WAIT 2
    REMOTE_REBOOT_WAIT ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}

    test -f /mnt/testnfs
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /mnt
    SSH_CMD "rm -rf /home/nfs;yum remove -y nfs-utils;mv -f /etc/exports.bak /etc/exports" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
