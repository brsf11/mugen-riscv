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
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-10-12
#@License       :   Mulan PSL v2
#@Desc          :   A wrapper for the user, group and hosts NSS API.
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function config_params() {
    LOG_INFO "Start to config params of the case."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    if ! grep 'Bruce_liu' /etc/passwd; then
        useradd Bruce_liu
    fi
    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL nss_wrapper
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    nss_wrapper.pl --help | grep 'usage'
    CHECK_RESULT $?
    su - Bruce_liu -c "cd /root" 2>&1 | grep 'Permission denied'
    CHECK_RESULT $?
    nss_wrapper.pl --action add --type member --member Bruce_liu --group_path /etc/group --name root --passwd_path /etc/passwd
    CHECK_RESULT $?
    su - Bruce_liu -c "cd /root;pwd" | grep '/root'
    CHECK_RESULT $?
    nss_wrapper.pl --action delete --type member --member Bruce_liu --group_path /etc/group --name root --passwd_path /etc/passwd
    CHECK_RESULT $?
    su - Bruce_liu -c "cd /root" 2>&1 | grep 'Permission denied'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    export LANG=${OLD_LANG}
    DNF_REMOVE
    userdel -rf Bruce_liu
    LOG_INFO "End to restore the test environment."
}

main "$@"
