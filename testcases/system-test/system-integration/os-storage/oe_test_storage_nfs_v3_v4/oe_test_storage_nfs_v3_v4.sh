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
# @Desc      :   Supported NFS versions, NFSv4, nfsv3
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
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
    SSH_CMD "yum install nfs-utils -y;mkdir /home/nfs;touch /home/nfs/testnfs;chmod 777 /home/nfs;
    mv /etc/exports /etc/exports.bak;echo '/home/nfs *(rw,sync,all_squash)' >/etc/exports" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "exportfs -avr; systemctl restart nfs-server rpcbind" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    mkdir -p /home/{client1,client2}
    systemctl restart nfs-server rpcbind
    mount -t nfs -o nfsvers=3 ${NODE2_IPV4}:/home/nfs /home/client1
    CHECK_RESULT $?
    df -h | grep ${NODE2_IPV4}
    CHECK_RESULT $?
    test -f /home/client1/testnfs
    CHECK_RESULT $?
    mount -t nfs -o nfsvers=4 ${NODE2_IPV4}:/home/nfs /home/client2
    CHECK_RESULT $?
    test -f /home/client2/testnfs
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /home/client1
    umount /home/client2
    rmdir home/{client1,client2}
    SSH_CMD "rm -rf /home/nfs;yum remove -y nfs-utils;mv -f /etc/exports.bak /etc/exports" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    systemctl start firewalld
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
