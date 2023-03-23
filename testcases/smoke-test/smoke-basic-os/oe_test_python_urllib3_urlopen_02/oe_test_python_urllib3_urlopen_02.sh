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
# @Desc      :   Test response.getcode
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    pip3 install fake_useragent
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF
        log_file testlog
        spawn python3
        expect ">>>" {send "import urllib\r"}
        expect ">>>" {send "import urllib.request\r"}
        expect ">>>" {send "import fake_useragent\r"}
        expect ">>>" {send "from fake_useragent import UserAgent\r"}
        expect ">>>" {send "ua = UserAgent()\r"}
        expect ">>>" {send "headers = {'User-Agent': ua.random}\r"}
        expect ">>>" {send "url = 'https://www.baidu.com/'\r"}
        expect ">>>" {send "request = urllib.request.Request(url=url, headers=headers)\r"}
        expect ">>>" {send "response = urllib.request.urlopen(request)\r"}
        expect ">>>" {send "response.read().decode('utf-8')\r"}
        expect ">>>" {send "response.getcode()\r"}
        expect ">>>" {send "exit()\r"}
        expect eof
EOF
    grep -E "data|body|html" testlog
    CHECK_RESULT $? 0 0 "Data return failed"
    grep -A 3 "response.getcode" testlog | grep 200
    CHECK_RESULT $? 0 0 "Status code return failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf testlog
    pip3 uninstall fake_useragent -y
    LOG_INFO "End to restore the test environment."
}

main "$@"
