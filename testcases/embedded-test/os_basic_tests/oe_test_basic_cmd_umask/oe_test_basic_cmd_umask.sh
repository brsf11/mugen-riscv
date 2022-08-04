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
# @Author    :   saarloos
# @Contact   :   9090-90-90-9090@163.com
# @Date      :   2022-07-06
# @License   :   Mulan PSL v2
# @Desc      :   Umask default configuration check
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."

    umaskValue=$(umask)
    umask 0037
    CHECK_RESULT $? 0 0 "set umask 0037 fail"
    umask | grep 0037
    CHECK_RESULT $? 0 0 "check umask 0037 fail"

    umask ${umaskValue}
    CHECK_RESULT $? 0 0 "set umask ${umaskValue} fail"
    umask | grep ${umaskValue}
    CHECK_RESULT $? 0 0 "check umask ${umaskValue} fail"

    LOG_INFO "End to run test."
}

main $@
