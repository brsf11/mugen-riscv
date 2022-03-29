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
# @Date      :   2020-04-29
# @License   :   Mulan PSL v2
# @Desc      :   User creates another cron file
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start executing testcase!"
    crontab -u root -l 2>&1 | grep 'no crontab'
    CHECK_RESULT $?
    touch ~/globus.cron
    crontab ~/globus.cron
    CHECK_RESULT $?
    echo "* 18-22/2 * * * LOG_INFO "sleepy" >> /tmp/test.txt" >>~/globus.cron
    CHECK_RESULT $?
    crontab ~/globus.cron
    ret=$(crontab -l | wc -l)
    CHECK_RESULT $ret 1
    crontab -r
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf ~/globus.cron
    LOG_INFO "Finish environment cleanup."
}

main $@
