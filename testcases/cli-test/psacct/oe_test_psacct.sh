#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   ice-kylin
#@Contact   	:   wminid@yeah.net
#@Date      	:   2021-08-03
#@License   	:   Mulan PSL v2
#@Desc      	:   command test psacct
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "psacct"
    LOG_INFO "End to prepare the test environment."
}

function run_test()
{
    LOG_INFO "Start to run test."
    systemctl status psacct.service --no-pager | grep inactive
    CHECK_RESULT $? 0 0 "log message: Failed to run command: systemctl status psacct.service --no-pager"
    if systemctl status psacct.service --no-pager; then
        INIT_STATUS=0
    fi
    systemctl start psacct.service
    CHECK_RESULT $? 0 0 "log message: Failed to run command: systemctl start psacct.service"
    ac -V
    CHECK_RESULT $? 0 0 "log message: Failed to run command: ac -V"
    ac | grep -E 'total[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: ac"
    ac -f /var/log/wtmp | grep -E 'total[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: ac -f /var/log/wtmp"
    ac --complain | grep -E 'total[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: ac --complain"
    ac --reboots | grep -E 'total[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: ac --reboots"
    ac --supplants | grep -E 'total[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: ac --supplants"
    ac --timewarps | grep -E 'total[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: ac --timewarps"
    ac --compatibility | grep -E 'total[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: ac --compatibility"
    ac -a | grep -E 'total[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: ac -a"
    ac -d | grep -E '(((Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[[:space:]]{1,}([[:space:]]|[0-9])[0-9])|Today)[[:space:]]{1,}total[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: ac -d"
    ac -d --print-year | grep -E '(((Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[[:space:]]{1,}([[:space:]]|[0-9])[0-9][[:space:]][0-9]{4,})|Today)[[:space:]]{1,}total[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: ac -d --print-year"
    ac -d --print-zeros | grep -E '(((Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[[:space:]]{1,}([[:space:]]|[0-9])[0-9])|Today)[[:space:]]{1,}total[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: ac -d --print-zeros"
    ac -p | grep -E '(root|total)[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: ac -p"
    ac root | grep -E 'total[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: ac root"
    ac --debug
    CHECK_RESULT $? 0 0 "log message: Failed to run command: ac --debug"
    sa -V
    CHECK_RESULT $? 0 0 "log message: Failed to run command: sa -V"
    sa /var/account/pacct | grep -E '[0-9]{1,}[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}re[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}cp[[:space:]]{1,}[0-9]{1,}avio[[:space:]]{1,}[0-9]{1,}k'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: sa /var/account/pacct"
    sa | grep -E '[0-9]{1,}[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}re[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}cp[[:space:]]{1,}[0-9]{1,}avio[[:space:]]{1,}[0-9]{1,}k'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: sa"
    sa -u | grep -E '[0-9]{1,}\.[0-9]{1,}[[:space:]]{1,}cpu[[:space:]]{1,}[0-9]{1,}k[[:space:]]{1,}mem[[:space:]]{1,}0[[:space:]]{1,}io'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: sa -u"
    sa -m | grep -E '[0-9]{1,}[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}re[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}cp[[:space:]]{1,}[0-9]{1,}avio[[:space:]]{1,}[0-9]{1,}k'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: sa -m"
    sa -c | grep -E '[0-9]{1,}[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}%[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}re[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}%[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}cp[[:space:]]{1,}[0-9]{1,}\.[0-9]{1,}%[[:space:]]{1,}[0-9]{1,}avio[[:space:]]{1,}[0-9]{1,}k'
    CHECK_RESULT $? 0 0 "log message: Failed to run command: sa -c"
    sa --debug
    CHECK_RESULT $? 0 0 "log message: Failed to run command: sa --debug"
    accton -V
    CHECK_RESULT $? 0 0 "log message: Failed to run command: accton -V"
    accton /var/account/pacct
    CHECK_RESULT $? 0 0 "log message: Failed to run command: accton /var/account/pacct"
    accton on
    CHECK_RESULT $? 0 0 "log message: Failed to run command: accton on"
    lastcomm -V
    CHECK_RESULT $? 0 0 "log message: Failed to run command: lastcomm -V"
    lastcomm
    CHECK_RESULT $? 0 0 "log message: Failed to run command: lastcomm"
    lastcomm -f /var/account/pacct
    CHECK_RESULT $? 0 0 "log message: Failed to run command: lastcomm -f /var/account/pacct"
    lastcomm sa
    CHECK_RESULT $? 0 0 "log message: Failed to run command: lastcomm sa"
    accton off
    CHECK_RESULT $? 0 0 "log message: Failed to run command: accton off"
    systemctl restart psacct.service
    CHECK_RESULT $? 0 0 "log message: Failed to run command: systemctl restart psacct.service"
    systemctl stop psacct.service
    CHECK_RESULT $? 0 0 "log message: Failed to run command: systemctl stop psacct.service"
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    if [ $INIT_STATUS -eq 0 ]; then
        systemctl start psacct.service
    fi
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
