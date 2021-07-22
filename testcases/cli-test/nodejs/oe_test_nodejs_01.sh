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
#@Date          :   2020-11-23
#@License       :   Mulan PSL v2
#@Desc          :   node.js is JavaScript running on the server side.
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL nodejs
    echo 'console.log("Hello,Kitty");' >my.js
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    node -h | grep 'Usage'
    CHECK_RESULT $?
    node --version | grep "$(rpm -qa nodejs | awk -F '-' '{print $2}')"
    CHECK_RESULT $?
    expect <<-END
    log_file testlog1
    spawn node
    expect ">"
    send "console.log('Hello,Kitty');\\n"
    expect eof
    exit
END
    grep -iE 'fail|error' testlog1
    CHECK_RESULT $? 1 0 'Command executed failed'
    node my.js | grep 'Hello,Kitty'
    CHECK_RESULT $?
    node -- my.js | grep 'Hello,Kitty'
    CHECK_RESULT $?
    node --abort_on_uncaught_exception my.js | grep 'Hello,Kitty'
    CHECK_RESULT $?
    node -c my.js
    CHECK_RESULT $?
    node --completion-bash | grep 'node_complete'
    CHECK_RESULT $?
    node -e console
    CHECK_RESULT $?
    node --inspect my.js | grep 'Hello,Kitty'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -f my.js testlog1
    LOG_INFO "End to restore the test environment."
}

main "$@"
