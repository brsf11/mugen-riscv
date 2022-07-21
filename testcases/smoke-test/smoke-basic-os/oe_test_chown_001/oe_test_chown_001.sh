#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
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

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    grep "test:" /etc/passwd && userdel -rf test
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    useradd test
    echo "${NODE1_PASSWORD}" | passwd test --stdin

    mkdir -p /tmp/tmp/tmp01

    [ $(ls -l /tmp/tmp | tail -n 1 | awk -F ' ' '{print $3}') == "root" ]
    CHECK_RESULT $?
    [ $(ls -l /tmp/tmp | tail -n 1 | awk -F ' ' '{print $4}') == "root" ]
    CHECK_RESULT $?

    chown -R test:test /tmp/tmp
    CHECK_RESULT $?
    own_user02=$(ls -l /tmp/tmp | tail -n 1 | awk -F ' ' '{print $3}')
    own_group02=$(ls -l /tmp/tmp | tail -n 1 | awk -F ' ' '{print $4}')

    [ "$own_user02" == "test" ]
    CHECK_RESULT $?
    [ "$own_group02" == "test" ]
    CHECK_RESULT $?

    chown --help | grep "Usage"
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    export LANG=${OLD_LANG}
    rm -rf /tmp/tmp
    userdel -rf test
    LOG_INFO "Finish environment cleanup!"
}

main $@
