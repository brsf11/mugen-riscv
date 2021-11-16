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
#@Date          :   2021-10-26 11:00:43
#@License   	:   Mulan PSL v2
#@Desc          :   verification ansible's commnd
#####################################
source ../common/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    Pre_Test
    echo "${NODE2_PASSWORD}" >/tmp/pass
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    ansible-inventory --help | grep "Usage:"
    CHECK_RESULT $? 0 0 "Check ansible-inventory --help failed."
    ansible-inventory --version | grep "ansible-inventory"
    CHECK_RESULT $? 0 0 "Check ansible-inventory --version failed."
    expect <<-END
    spawn ansible-console ${NODE2_IPV4}
    expect "$"
    send "exit\n"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check ansible-console failed."
    expect <<-END
    spawn ansible-console --ask-vault-pass ${NODE2_IPV4}
    expect "password:"
    send "${NODE2_PASSWORD}\n"
    expect "$"
    send "exit\n"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check ansible-console --ask-vault-pass failed."
    expect <<-END
    spawn ansible-console --vault-password-file=/tmp/pass ${NODE2_IPV4}
    expect "$"
    send "exit\n"
    expect eof
END
    CHECK_RESULT $? 0 0 "Check ansible-console --vault-password failed."
    ansible-playbook --help | grep "Usage:"
    CHECK_RESULT $? 0 0 "Check ansible-playbook --help failed."
    ansible-playbook --version | grep "ansible-playbook"
    CHECK_RESULT $? 0 0 "Check ansible-playbook --version failed."
    ansible-pull --help | grep "Usage:"
    CHECK_RESULT $? 0 0 "Check ansible-pull --help failed."
    ansible-pull --version | grep "ansible-pull"
    CHECK_RESULT $? 0 0 "Check ansible-pull --version failed."
    ansible-vault --help | grep "Usage:"
    CHECK_RESULT $? 0 0 "Check ansible-vault --help failed."
    ansible-vault --version | grep "ansible-vault"
    CHECK_RESULT $? 0 0 "Check ansible-vault --version failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    Post_Test
    rm -rf /tmp/pass
    LOG_INFO "End to restore the test environment."
}
main "$@"
