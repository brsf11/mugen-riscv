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
# @Desc      :   Configure NFSv4 only servers
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL nfs-utils
    systemctl stop firewalld
    iptables -F
    SSH_CMD "systemctl stop firewalld;iptables -F;yum install nfs-utils -y;
    mkdir /home/nfs;chmod 777 /home/nfs;mv /etc/exports /etc/exports.bak;
    echo '/home/nfs *(rw,sync,all_squash)' >/etc/exports" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "exportfs -avr" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "systemctl restart nfs-server rpcbind" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    SSH_CMD "sed -i 's/^#\\\ vers2=n/vers2=n/g' /etc/nfs.conf;sed -i 's/^#\\\ vers3=y/vers3=n/g' /etc/nfs.conf;
    systemctl restart nfs-server rpcbind" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}

    mkdir /home/client
    systemctl restart nfs-server rpcbind
    mount -t nfs -o nfsvers=2 ${NODE2_IPV4}:/home/nfs /home/client
    CHECK_RESULT $? 32
    mount -t nfs -o nfsvers=3 ${NODE2_IPV4}:/home/nfs /home/client
    CHECK_RESULT $? 32
    mount -t nfs -o nfsvers=4 ${NODE2_IPV4}:/home/nfs /home/client
    CHECK_RESULT $?
    df -h | grep ${NODE2_IPV4}
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /home/client
    rmdir /home/client
    SSH_CMD "rm -rf /home/nfs;yum remove -y nfs-utils;mv -f /etc/exports.bak /etc/exports" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
