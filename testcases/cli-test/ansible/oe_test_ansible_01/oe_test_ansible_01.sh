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
    ansible --version | grep "ansible"
    CHECK_RESULT $? 0 0 "Check ansible --version failed."
    ansible --help | grep "Usage:"
    CHECK_RESULT $? 0 0 "Check ansible --help failed."
    SLEEP_WAIT 5 "ansible -m ping all|grep \"SUCCESS\"" 2
    CHECK_RESULT $? 0 0 "Check ansible -mfailed."
    SLEEP_WAIT 5 "ansible all -m ping -u root|grep \"SUCCESS\"" 2
    CHECK_RESULT $? 0 0 "Check ansible -m ping failed."
    SLEEP_WAIT 5 "ansible all -e \"ansible-python-interpreter=auto-legacy-silent\" -m ping|grep \"SUCCESS\"" 2
    CHECK_RESULT $? 0 0 "Check ansible -e failed."
    SLEEP_WAIT 5 "ansible -a \"echo hello\" ${NODE2_IPV4}|grep \"hello\"" 2
    CHECK_RESULT $? 0 0 "Check ansible -a failed."
    SLEEP_WAIT 5 "ansible '*' -m command -a 'uptime'|grep \"SUCCESS\"" 2
    CHECK_RESULT $? 0 0 "Check ansible -m update failed."
    SLEEP_WAIT 5 "ansible -m command -a \"date -R\" ${NODE2_IPV4}|grep \"SUCCESS\"" 2
    CHECK_RESULT $? 0 0 "Check ansible -m date -R failed."
    SLEEP_WAIT 5 "ansible -m shell -a 'ps -ef|grep sshd|grep -v grep' ${NODE2_IPV4} -v|grep \"SUCCESS\"" 2
    CHECK_RESULT $? 0 0 "Check ansible -m shell failed."
    SLEEP_WAIT 5 "ansible all -m group -a 'gid=2017 name=a'|grep \"present\"" 2
    CHECK_RESULT $? 0 0 "Check ansible -m group failed."
    SLEEP_WAIT 5 "ansible all -m user -a 'name=aaa groups=a state=present'|grep \"\"name\": \"aaa\",\"" 2
    CHECK_RESULT $? 0 0 "Check ansible -m user failed."
    SLEEP_WAIT 5 "ansible all -m user -a 'name=aaa groups=a remove=yes'|grep \"SUCCESS\"" 2
    CHECK_RESULT $? 0 0 "Check ansible -m -a remove failed."
    SLEEP_WAIT 5 "ansible all -m raw -a \"ps aux|grep zabbix|awk '{print \$2}'\"|grep \"SUCCESS\"" 2
    CHECK_RESULT $? 0 0 "Check ansible -m raw failed."
    SLEEP_WAIT 5 "ansible all -m copy -a \"src=/opt/test dest=./\" -vv|grep \"SUCCESS\"" 2
    CHECK_RESULT $? 0 0 "Check ansible -m -vv failed."
    SLEEP_WAIT 5 "ansible all -m group -a \"name=jason10 system=yes gid=5000\"|grep \"\"name\": \"jason10\",\"" 2
    CHECK_RESULT $? 0 0 "Check ansible -m system=yes failed."
    SLEEP_WAIT 5 "ansible all -m shell -a \"chdir=. touch f2\" -vv|grep \"SUCCESS\"" 2
    CHECK_RESULT $? 0 0 "Check ansible -vv -a failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    Post_Test
    LOG_INFO "End to restore the test environment."
}
main "$@"
