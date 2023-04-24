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
# @Author    :   gaomingyang
# @Contact   :   gaomingyang@uniontech.com
# @Date      :   2022-12-06
# @License   :   Mulan PSL v2
# @Desc      :   test find
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start testing..."
    find  /proc  -name cpuinfo | grep '/proc/cpuinfo'
    CHECK_RESULT $? 0 0 "find fail"
    useradd -m test1
    CHECK_RESULT $? 0 0 "useradd fail"
    find /home  -group  test1 | grep '/home/test1'
    CHECK_RESULT $? 0 0 "find fail"
    find --help | grep "Usage: find"
    CHECK_RESULT $? 0 0 "find fail"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel test1 -rf
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
