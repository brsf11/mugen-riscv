#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
#@Date          :   2020-07-23
#@License       :   Mulan PSL v2
#@Desc          :   Application scenarios: symmetrically encrypts and decrypts files
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    cat >test.txt <<EOF
    This is a file created by shell.
    We want to make a good world.
    Byebye!
EOF
    expect <<-END
    log_file testlog1
    spawn openssl enc -aes-256-cbc -salt -in test.txt -out test.enc
    expect "enter aes-256-cbc encryption password:"
    send "123123\\n"
    expect "Verifying - enter aes-256-cbc encryption password:"
    send "123123\\n"
    expect eof
    exit
END
    grep 'better' testlog1
    CHECK_RESULT $?
    test -f test.enc
    CHECK_RESULT $?
    expect <<-END
    log_file testlog2
    spawn openssl enc -d -aes-256-cbc -in test.enc
    expect "enter aes-256-cbc decryption password:"
    send "123123\\n"
    expect eof
    exit
END
    grep 'Byebye!' testlog2
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f test.txt test.enc testlog*
    LOG_INFO "End to restore the test environment."
}

main "$@"
