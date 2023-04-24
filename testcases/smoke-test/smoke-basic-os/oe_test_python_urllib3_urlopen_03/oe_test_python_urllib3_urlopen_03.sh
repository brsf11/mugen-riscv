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
# @Date      :   2022/07/18
# @License   :   Mulan PSL v2
# @Desc      :   Test request timeout
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF
        log_file testlog
        spawn python3
        expect ">>>" {send "import urllib\r"}
        expect ">>>" {send "import urllib.request\r"}
        expect ">>>" {send "from urllib.parse import urlparse\r"}
        expect ">>>" {send "parsed_result=urlparse('http://baidu123.com/')\r"}
        expect ">>>" {send "print(parsed_result)\r"}
        expect ">>>" {send "urllib.request.urlopen('http://gitee.com',timeout=2)\r"}
        expect ">>>" {send "urllib.request.urlopen('http://gite.com',timeout=0.1)\r"}
        expect ">>>" {send "exit()\r"}
        expect eof
EOF
    grep "timed out" testlog
    CHECK_RESULT $? 0 0 "No timeout"
    grep -E "scheme|netloc|path" testlog
    CHECK_RESULT $? 0 0 "Parsing failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf testlog
    LOG_INFO "End to restore the test environment."
}

main "$@"
