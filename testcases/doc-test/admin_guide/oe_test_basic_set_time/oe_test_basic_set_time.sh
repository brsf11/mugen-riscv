#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2020.04-27
# @License   :   Mulan PSL v2
# @Desc      :   Use the timedatectl command to set the time
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    time=$(date "+%Y-%m-%d %H:%M:%S")
    timedatectl set-ntp no
    SLEEP_WAIT 5
    localzone=$(timedatectl | sed -n '4p' | cut -d ":" -f 2 | awk '{print$1}')
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    timedatectl | grep "Local time"
    CHECK_RESULT $?
    timedatectl set-ntp yes
    CHECK_RESULT $?
    SLEEP_WAIT 5
    timedatectl | grep "NTP service" | grep " active"
    CHECK_RESULT $?
    timedatectl set-ntp no
    SLEEP_WAIT 5
    timedatectl set-time '2019-08-14'
    CHECK_RESULT $?
    timedatectl | grep "Local time" | grep "2019-08-14"
    CHECK_RESULT $?
    timedatectl set-time 15:00:00
    CHECK_RESULT $?
    timedatectl | grep "Local time" | grep "15:00"
    CHECK_RESULT $?
    ret=$(timedatectl list-timezones | grep -c Asia)
    CHECK_RESULT $ret 0 1
    timedatectl set-timezone Asia/Beijing
    timedatectl | grep "Asia\/Beijing"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    timedatectl set-timezone ${localzone}
    timedatectl set-ntp yes
    LOG_INFO "Finish environment cleanup."
}

main $@
