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
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date          :   2021-10-25 14:00:43
#@License   	:   Mulan PSL v2
#@Desc          :   verification ansible's commnd
#####################################
source ../common/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    Pre_Test
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ansible-config --version | grep "ansible-config"
    CHECK_RESULT $? 0 0 "Check ansible-config --version failed."
    ansible-config --help | grep "Usage:"
    CHECK_RESULT $? 0 0 "Check ansible-config --help failed."
    expect <<-END
    spawn ansible-config view
    expect ":"
    send "wq"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check ansible-config view failed."
    expect <<-END
    spawn ansible-config dump
    expect ":"
    send "wq"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check ansible-config dump failed."
    expect <<-END
    spawn ansible-config list -v
    expect ":"
    send "wq"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check ansible-config list -v failed."
    ansible-console --help | grep "Usage:"
    CHECK_RESULT $? 0 0 "Check ansible-console --help failed."
    ansible-console --version | grep "ansible-console"
    CHECK_RESULT $? 0 0 "Check ansible-console --version failed."
    expect <<-END
    spawn ansible-console
    expect "$"
    send "ip a\n"
    expect "$"
    send "ls\n"
    expect "$"
    send "exit\n"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check ansible-console failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    Post_Test
    LOG_INFO "End to restore the test environment."
}
main "$@"
