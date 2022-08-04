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
# @Desc      :   File system common command test-chmod
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    ls /tmp/test01 && rm -rf /tmp/test01
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    mkdir -p /tmp/test01/test02/test03
    ls -l /tmp | grep "test01" | awk -F ' ' '{print $1}' | grep "drwxr-xr-x"
    CHECK_RESULT $?
    per01=$(ls -l /tmp/test01 | grep "test02" | awk -F ' ' '{print $1}')
    chmod 777 /tmp/test01
    ls -l /tmp | grep "test01" | awk -F ' ' '{print $1}' | grep "drwxrwxrwx"
    CHECK_RESULT $?
    per02=$(ls -l /tmp/test01 | grep "test02" | awk -F ' ' '{print $1}')
    [ "$per01" == "$per02" ]
    CHECK_RESULT $?

    chmod -R 777 /tmp/test01
    ls -l /tmp/ | grep "test01" | awk -F ' ' '{print $1}' | grep "drwxrwxrwx"
    CHECK_RESULT $?
    ls -l /tmp/test01 | grep "test02" | awk -F ' ' '{print $1}' | grep "drwxrwxrwx"
    CHECK_RESULT $?

    chmod --help | grep "Usage"
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /tmp/test01
    export LANG=${OLD_LANG}
    LOG_INFO "Finish environment cleanup!"
}

main $@
