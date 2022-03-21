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
# @Desc      :   File system common command test-chmod
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    test -d /tmp/test01/test02/test03 || mkdir -p /tmp/test01/test02/test03
    per01=$(ls -l /tmp | grep "test01" | awk -F ' ' '{print $1}')
    per02=$(ls -l /tmp/test01 | grep "test02" | awk -F ' ' '{print $1}')
    chmod 777 /tmp/test01
    per03=$(ls -l /tmp | grep "test01" | awk -F ' ' '{print $1}')
    per04=$(ls -l /tmp/test01 | grep "test02" | awk -F ' ' '{print $1}')
    per05=$(ls -l /tmp/ | grep "test01" | awk -F ' ' '{print $1}')
    per06=$(ls -l /tmp/test01 | grep "test02" | awk -F ' ' '{print $1}')
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    echo $per03 | grep "drwxrwxrwx"
    CHECK_RESULT $?
    [ "$per02" == "$per04" ]
    CHECK_RESULT $?
    echo $per05 | grep "drwxrwxrwx" 
    CHECK_RESULT $?
    echo $per06 | grep  "drwxr-xr-x" 
    CHECK_RESULT $?
    chmod --help | grep -i "Usage"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /tmp/test01
    LOG_INFO "Finish environment cleanup."
}

main $@
