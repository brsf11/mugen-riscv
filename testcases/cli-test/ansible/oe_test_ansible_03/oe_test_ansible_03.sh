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
#@Date          :   2021-10-26 9:00:43
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
    ansible-doc --help | grep "Usage:"
    CHECK_RESULT $? 0 0 "Check ansible-doc --help failed."
    ansible-doc --version | grep "ansible-doc"
    CHECK_RESULT $? 0 0 "Check ansible-doc --version failed."
    expect <<-END
    spawn ansible-doc -l
    expect ":"
    send "wq"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check ansible-doc -l failed."
    SLEEP_WAIT 5 "ansible-doc -s mysql_user|grep \"mysql_user:\"" 2
    CHECK_RESULT $? 0 0 "Check ansible-doc -s failed."
    expect <<-END
    spawn ansible-doc -a
    expect ":"
    send "wq"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check ansible-doc -a failed."
    ansible-galaxy --help | grep "Usage:"
    CHECK_RESULT $? 0 0 "Check ansible-galaxy --help failed."
    ansible-galaxy --version | grep "ansible-galaxy"
    CHECK_RESULT $? 0 0 "Check ansible-galaxy --version failed."
    ansible-galaxy list
    CHECK_RESULT $? 0 0 "Check ansible-galaxy list failed."
    SLEEP_WAIT 5 "ansible-galaxy search geerlingguy.nginx|grep \"roles matching your search:\"" 2
    CHECK_RESULT $? 0 0 "Check ansible-galaxy search failed."
    SLEEP_WAIT 5 "ansible-galaxy info geerlingguy.nginx|grep \"description:\"" 2
    CHECK_RESULT $? 0 0 "Check ansible-galaxy info failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    Post_Test
    LOG_INFO "End to restore the test environment."
}
main "$@"
