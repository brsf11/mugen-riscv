#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
#@Date          :   2020-10-28
#@License       :   Mulan PSL v2
#@Desc          :   (pcp-system-tools) (pcp-iostat)
#####################################

source "common/common_pcp-system-tools.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    archive_data=$(pcp -h "$host_name" | grep 'primary logger:' | awk -F: '{print $NF}')
    disk_name=$(lsblk | grep 'disk' | awk '{print $1}')
    OLD_PATH=$PATH
    export PATH=/usr/libexec/pcp/bin/:$PATH
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    SLEEP_WAIT 60
    pcp-iostat --version 2>&1 | grep "$pcp_version"
    CHECK_RESULT $?
    pcp-iostat -a $archive_data -A 10min -s 10 | grep 'rrqm/s'
    CHECK_RESULT $?
    pcp-iostat -a $archive_data -G sum -s 10 | grep 'sum(.*)'
    CHECK_RESULT $?
    pcp-iostat -h $host_name -s 10 | grep 'wrqm/s'
    CHECK_RESULT $?
    pcp-iostat -a $archive_data -O @08 -s 10 -t 2 | grep 'r/s'
    CHECK_RESULT $?
    pcp-iostat -a $archive_data -P 1 -s 10 | grep 'w/s'
    CHECK_RESULT $?
    pcp-iostat -a $archive_data -R $disk_name -s 10 | grep "$disk_name"
    CHECK_RESULT $?
    pcp-iostat -a $archive_data -S @00 -T @23 -s 10 | grep 'rkB/s'
    CHECK_RESULT $?
    pcp-iostat -a $archive_data -u -s 10 | grep 'wkB/s'
    CHECK_RESULT $?
    pcp-iostat -Z Africa/Lagos -s 10 | grep 'Device'
    CHECK_RESULT $?
    pcp-iostat -a $archive_data -z -s 10 | grep 'avgrq-sz'
    CHECK_RESULT $?
    pcp-iostat -a $archive_data -x dm -s 5 | grep 'avgqu-sz'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    PATH=${OLD_PATH}
    LOG_INFO "End to restore the test environment."
}

main "$@"
