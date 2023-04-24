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
# @Desc      :   Test subprocess.Popen
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF
        log_file testlog
        spawn python3
        expect ">>>" {send "import subprocess\r"}
        expect ">>>" {send "import os\r"}
        expect ">>>" {send "subprocess.Popen('uname', close_fds=False)\r"}
        expect ">>>" {send "exit()\r"}
        expect eof
EOF
    grep $(uname) ./testlog
    CHECK_RESULT $? 0 0 "Failed to execute close_fds=False"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf testlog
    LOG_INFO "End to restore the test environment."
}

main "$@"
