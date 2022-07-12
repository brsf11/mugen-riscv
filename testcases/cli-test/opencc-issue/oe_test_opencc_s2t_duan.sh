#!/usr/bin/bash

# Copyright (c) 2020. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2021/01/20
# @License   :   Mulan PSL v2
# @Desc      :   Translation from simple to complex
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL opencc
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    echo '发放' | opencc -c s2t | grep '發放'
    CHECK_RESULT $?
    echo '确保补贴临时补充及时足额发放到位' | opencc -c s2t | grep '確保補貼臨時補充及時足額髮放到位'
    CHECK_RESULT $?
    echo '困难' | opencc -c s2t | grep '困難'
    CHECK_RESULT $?
    echo '为进一步保障好困难群众生活' | opencc -c s2t | grep '爲進一步保障好睏難羣衆生活'
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}
function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE 1
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
