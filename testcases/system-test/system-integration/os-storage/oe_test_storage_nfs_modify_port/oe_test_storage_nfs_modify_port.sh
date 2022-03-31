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
# @Desc      :   Modify NFS server operation port
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL nfs-utils
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    systemctl enable --now rpc-rquotad
    CHECK_RESULT $?
    sed -i '/\[mountd\]/a\port=1299' /etc/nfs.conf
    cp /etc/exports /etc/exports.bak
    echo "/home/nfs *(rw,sync,all_squash)" >/etc/exports
    mkdir /home/nfs
    systemctl start nfs-server
    CHECK_RESULT $?
    rpcinfo -p | grep -iE "mountd|nfs" | grep -iE "tcp|udp"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf /home/nfs
    mv -f /etc/exports.bak /etc/exports
    LOG_INFO "Finish environment cleanup."
}

main $@
