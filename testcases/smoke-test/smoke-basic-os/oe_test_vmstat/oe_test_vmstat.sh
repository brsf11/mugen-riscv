#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   dengailing
# @Contact   :   dengailing@uniontech.com
# @Date      :   2022-12-13
# @License   :   Mulan PSL v2
# @Desc      :   test vmstat
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"


function run_test() {
    LOG_INFO "Start testing..."
    vmstat -h
    CHECK_RESULT $? 0 0 "vmstat -h fail"
    vmstat -V 
    CHECK_RESULT $? 0 0 "vmstat -V fail"
    vmstat
    CHECK_RESULT $? 0 0 "vmstat fail"
    vmstat -f
    CHECK_RESULT $? 0 0 "vmstat -f fail"
    vmstat -w
    CHECK_RESULT $? 0 0 "vmstat -w fail"
    vmstat -t
    CHECK_RESULT $? 0 0 "vmstat -t fail"
    vmstat -s
    CHECK_RESULT $? 0 0 "vmstat -s fail"
    vmstat -d
    CHECK_RESULT $? 0 0 "vmstat -d fail"
    LOG_INFO "Finish test!"
}

main "$@"
