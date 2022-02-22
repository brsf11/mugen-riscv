#/usr/bin/bash

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
# @Desc      :   File system common command test-wc
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start loading data!"
    line01=$(wc /proc/cpuinfo | awk '{print $1}')
    word01=$(wc /proc/cpuinfo | awk '{print $2}')
    byte01=$(wc /proc/cpuinfo | awk '{print $3}')
    line02=$(wc -l /proc/cpuinfo | awk '{print $1}')
    byte02=$(wc -c /proc/cpuinfo | awk '{print $1}')
    word02=$(wc -w /proc/cpuinfo | awk '{print $1}')
    LOG_INFO "End loading data!!"
}
function run_test() {
    LOG_INFO "Start executing testcase!"
    wc /proc/cpuinfo
    CHECK_RESULT $?
    wc -l /proc/cpuinfo
    CHECK_RESULT $?
    wc -w /proc/cpuinfo
    CHECK_RESULT $?
    wc -c /proc/cpuinfo
    CHECK_RESULT $?
    [[ ${line01} -eq ${line02} && ${word01} -eq ${word02} && ${byte01} -eq ${byte02} ]]
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

main $@
