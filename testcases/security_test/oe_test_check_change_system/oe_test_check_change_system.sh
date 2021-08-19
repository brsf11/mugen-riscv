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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Modify    :   yang_lijin@qq.com
# @Date      :   2021/08/10
# @License   :   Mulan PSL v2
# @Desc      :   Support check and change the system encryption policy
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."
    update-crypto-policies --show | grep DEFAULT
    CHECK_RESULT $? 0 0 "update-crypto-policies is not DEFAULT"
    update-crypto-policies --set FUTURE
    update-crypto-policies --show | grep FUTURE
    CHECK_RESULT $? 0 0 "set update-crypto-policies FUTURE failed"
    update-crypto-policies --set legacy
    update-crypto-policies --show | grep LEGACY
    CHECK_RESULT $? 0 0 "set update-crypto-policies LEGACY failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    update-crypto-policies --set DEFAULT
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
