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
#@Date          :   2020-10-14
#@License       :   Mulan PSL v2
#@Desc          :   pcp testing(dbpmda)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    expect <<-END
    log_file testlog1
    spawn dbpmda -n /var/lib/pcp/pmns/root
    expect "dbpmda>"
    send "quit\\n"
    expect eof
    exit
END
    grep -iE 'fail|error' testlog1
    CHECK_RESULT $? 1 0 'dbpmda_n Command executed failed'
    expect <<-END
    log_file testlog2
    spawn dbpmda -f
    expect "dbpmda>"
    send "quit\\n"
    expect eof
    exit
END
    grep -iE 'fail|error' testlog2
    CHECK_RESULT $? 1 0 'dbpmda_f Command executed failed'
    expect <<-END
    log_file testlog3
    spawn dbpmda -q 3
    expect "dbpmda>"
    send "quit\\n"
    expect eof
    exit
END
    grep -iE 'fail|error' testlog3
    CHECK_RESULT $? 1 0 'dbpmda_q Command executed failed'
    expect <<-END
    log_file testlog4
    spawn dbpmda -U root
    expect "dbpmda>"
    send "quit\\n"
    expect eof
    exit
END
    grep -iE 'fail|error' testlog4
    CHECK_RESULT $? 1 0 'dbpmda_U Command executed failed'
    expect <<-END
    log_file testlog5
    spawn dbpmda -e
    expect "dbpmda>"
    send "quit\\n"
    expect eof
    exit
END
    grep -iE 'fail|error' testlog5
    CHECK_RESULT $? 1 0 'dbpmda_e Command executed failed'
    expect <<-END
    log_file testlog6
    spawn dbpmda -i
    expect "dbpmda>"
    send "help\\n"
    expect "dbpmda>"
    send "timer on\\n"
    expect "dbpmda>"
    send "timer off\\n"
    expect "dbpmda>"
    send "status\\n"
    expect "dbpmda>"
    send "close\\n"
    expect "dbpmda>"
    send "wait 3\\n"
    expect "dbpmda>"
    send "debug all\\n"
    expect "dbpmda>"
    send "label context\\n"
    expect "dbpmda>"
    send "quit\\n"
    expect eof
    exit
END
    grep "help \[ command \]" testlog6
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -f testlog*
    LOG_INFO "End to restore the test environment."
}

main "$@"
