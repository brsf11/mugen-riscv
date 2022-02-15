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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-10
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-chown
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start pre testcase!"
    grep -w test /etc/passwd || useradd test
    echo ${NODE1_PASSWORD} | passwd test --stdin
    test -d tmp/tmp01 || mkdir -p tmp/tmp01
    sudo chown -R test:test tmp
    own_user02=$(ls -l tmp | tail -n 1 | awk -F ' ' '{print $3}')
    own_group02=$(ls -l tmp | tail -n 1 | awk -F ' ' '{print $4}')
    LOG_INFO "End pre testcase!"
}
function run_test() {
    LOG_INFO "Start executing testcase!"
    [ "$own_user02" == "test" ]
    CHECK_RESULT $?
    [ "$own_group02" == "test" ]
    CHECK_RESULT $?
    chown --help | grep -i "Usage"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -r test
    rm -rf tmp
    LOG_INFO "Finish environment cleanup."
}

main $@
