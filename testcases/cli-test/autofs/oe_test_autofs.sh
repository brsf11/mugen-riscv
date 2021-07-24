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
#@Desc          :   Autofs is a program that can automatically load the specified directory as needed.
#####################################

source "common/common_autofs.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    map_name=/etc/auto.master
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    automount_daemon_id=$(pgrep -f "automount --foreground --dont-check-daemon")
    [ -n "$automount_daemon_id" ]
    CHECK_RESULT $?
    automount -h 2>&1 | grep 'Usage'
    CHECK_RESULT $?
    automount -V | grep "$(rpm -qa autofs | awk -F '-' '{print $2}')"
    CHECK_RESULT $?
    automount -p /tmp/automount_pid $map_name
    CHECK_RESULT $?
    test $(cat /tmp/automount_pid) -eq $(pgrep -f automount_pid)
    CHECK_RESULT $?
    kill -9 $(pgrep -f automount_pid)
    CHECK_RESULT $?
    automount -M 20 $map_name
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'automount -M')
    CHECK_RESULT $?
    automount -d $map_name
    CHECK_RESULT $?
    kill -9 $(pgrep -f 'automount -d')
    CHECK_RESULT $?
    automount -m -v $map_name | grep "autofs dump map information"
    CHECK_RESULT $?
    touch /run/autofs.fifodevel
    automount -l 2 devel | grep "Successfully set log priority for devel"
    CHECK_RESULT $?
    grep -a '2' /run/autofs.fifodevel
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
