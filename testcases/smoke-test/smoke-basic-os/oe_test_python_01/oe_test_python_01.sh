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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/07/14
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of python
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    system_name=$(grep PRETTY_NAME /etc/os-release | awk -F '="' '{print $2}' | awk '{print $1}')
    system_version=$(grep PRETTY_NAME /etc/os-release | awk -F '="' '{print $2}' | awk '{print $2}' | awk -F '"' '{print$1}')
    kernel_version=$(uname -a | awk '{print $3}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF
        log_file testlog
        spawn python3
        expect ">>>" {send "import platform\r"}
        expect ">>>" {send "import distro\r"}
        expect ">>>" {send "distro.linux_distribution()\r"}
        expect ">>>" {send "platform.platform()\r"}
        expect ">>>" {send "exit()\r"}
        expect eof
EOF
    grep $system_name ./testlog
    CHECK_RESULT $? 0 0 "system_name display failed"
    grep $system_version ./testlog
    CHECK_RESULT $? 0 0 "system_version display failed"
    grep $kernel_version ./testlog
    CHECK_RESULT $? 0 0 "kernel_version display failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf testlog
    LOG_INFO "End to restore the test environment."
}

main "$@"
