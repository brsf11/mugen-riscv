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
#@Date          :   2020-07-22
#@License       :   Mulan PSL v2
#@Desc          :   Encryption algorithm: generate a password
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    echo "Hello, world!" >word
    openssl passwd -crypt -salt 12345 root
    CHECK_RESULT $?
    openssl passwd -crypt -in word -salt 12345
    CHECK_RESULT $?
    openssl passwd -1 -in word -salt 12345
    CHECK_RESULT $?
    expect <<-END
    log_file testlog1
    spawn openssl passwd -1 -salt 12345 -stdin
    expect ""
    send "1\\n"
    expect ""
    send "11\\n"
    expect ""
    send "111\\n"
    expect eof
    exit
END
    grep '111' testlog1
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f word testlog1
    LOG_INFO "End to restore the test environment."
}

main "$@"
