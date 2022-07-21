#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   lutianxiong
# @Contact   :   lutianxiong@huawei.com
# @Date      :   2020-07-20
# @License   :   Mulan PSL v2
# @Desc      :   nfs test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function config_params() {
    LOG_INFO "Start to config params of the case."
    test_user=nfs_test_$$
    server_dir=/home/nfs_server_$$
    client_dir=/home/nfs_client_$$
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    DNF_INSTALL "nfs-utils nfs4-acl-tools"
    useradd $test_user
    mkdir $server_dir $client_dir
    test -f /etc/exports && cp /etc/exports .
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    echo "$server_dir *(rw,sync,no_root_squash)" >>/etc/exports
    systemctl restart nfs-server
    CHECK_RESULT $?
    systemctl status nfs-server | grep 'Active: active'
    CHECK_RESULT $?
    systemctl restart rpcbind
    CHECK_RESULT $?
    systemctl status rpcbind | grep 'Active: active'
    CHECK_RESULT $?
    showmount -e localhost | grep -w "$server_dir"
    CHECK_RESULT $?
    mount -t nfs4 localhost:$server_dir $client_dir
    CHECK_RESULT $?
    echo "$$" >$client_dir/file
    diff $server_dir/file $client_dir/file
    CHECK_RESULT $?
    chmod 640 $client_dir/file
    sudo -u $test_user cat $client_dir/file 2>/tmp/error.log && return 1
    grep "Permission denied" /tmp/error.log
    CHECK_RESULT $?
    uid=$(id -u $test_user)
    nfs4_setfacl -a "A::${uid}:r" $client_dir/file
    CHECK_RESULT $?
    nfs4_getfacl $client_dir/file | grep "A::${uid}:r"
    CHECK_RESULT $?
    sudo -u $test_user cat $client_dir/file
    umount $client_dir
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount $client_dir
    rm -rf $client_dir $server_dir
    userdel -r $test_user
    rm -f /tmp/error.log
    test -f exports && mv exports /etc/exports
    DNF_REMOVE
    export LANG=${OLD_LANG}
    LOG_INFO "Finish environment cleanup!"
}

main $@
