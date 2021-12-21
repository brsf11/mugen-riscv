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
# @Date      :   2020.04-09 10:52:41
# @License   :   Mulan PSL v2
# @Desc      :   Date command line test
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start prepare the test environment!"
    time=$(date "+%Y-%m-%d %H:%M:%S")
    year=$(echo ${time} | awk '{print$1}' | cut -d "-" -f1)
    LOG_INFO "End of prepare the test environment!"
}
function run_test() {
    LOG_INFO "Start executing testcase!" 
    date | grep ${year} | grep -i 'cst'
    CHECK_RESULT $?
    date01=$(date | awk -F ' ' '{print $1,$2,$3}')
    date -d 2020.01-01 | grep "Wed Jan  1 00:00:00 CST 2020."
    date02=$(date | awk -F ' ' '{print $1,$2,$3}')
    [ "$date01" == "$date02" ]
    CHECK_RESULT $? $date01 $date02
    date -s "10:30:00" | grep "10:30:00"
    CHECK_RESULT $?
    date -s "2015-02-04 10:30:00" | grep "10:30:00" | grep 2015 | grep -i feb | grep -i wed
    CHECK_RESULT $?
    hwclock -w
    CHECK_RESULT $?
    timedatectl | grep -i "rtc time" | grep "2015-02-04"
    CHECK_RESULT $?
    date -s "$time"
    CHECK_RESULT $?
    hwclock -w
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

main $@
