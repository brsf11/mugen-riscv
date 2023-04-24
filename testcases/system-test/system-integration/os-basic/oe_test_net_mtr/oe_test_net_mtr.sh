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
# @Author    :   fuyh2020
# @Contact   :   fuyahong@uniontech.com
# @Date      :   2022-11-08
# @License   :   Mulan PSL v2
# @Desc      :   Command test mtr
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "mtr"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    mtr -v 
    CHECK_RESULT $? 0 0 "check mtr version error"
    mtr -h
    CHECK_RESULT $? 0 0 "check mtr help error"
    mtr -r  dns.google -c 15 > mtr.tmp1 2>&1
    CHECK_RESULT $? 0 0 "execute -r -c cmd error"
    s_value=$(grep "_gateway" mtr.tmp1 | awk '{print $4}')
    CHECK_RESULT ${s_value} 15 0 "check log error after execute -r -c"
    mtr -r -s 50 dns.google
    CHECK_RESULT $? 0 0 "execute -r -s cmd error"
    mtr --xml dns.google > mtr.tmp2 2>&1
    CHECK_RESULT $? 0 0 "execute --xml cmd error"
    grep "_gateway" mtr.tmp2  | grep '<HUB' | grep '>'
    CHECK_RESULT $? 0 0 "check log error after execute --xml"
    mtr --csv dns.google > mtr.tmp3 2>&1
    CHECK_RESULT $? 0 0 "execute --csv cmd error"
    target_value=$(grep "_gateway" mtr.tmp3 | awk -F ',' '{print $6}')
    CHECK_RESULT ${target_value} "_gateway" 0 "check log error after execute --csv"
    mtr -T -r dns.google 
    CHECK_RESULT $? 0 0 "execute -T -r cmd error"
    mtr -u -r dns.google
    CHECK_RESULT $? 0 0 "execute -u -r cmd error"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf mtr.tmp*
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
