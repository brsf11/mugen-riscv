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
# @Date      :   2021/02/01
# @License   :   Mulan PSL v2
# @Desc      :   Check in TSPrases.txt The corresponding transformation of "藉" and "覆" in dictionaries
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL opencc
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    opencc_dict -i /usr/share/opencc/TSPhrases.ocd -o /tmp/TSPhrases.txt -f ocd -t text
    CHECK_RESULT $?
    grep '以功覆過' /tmp/TSPhrases.txt | grep '以功覆过'
    CHECK_RESULT $?
    grep '狐藉虎威' /tmp/TSPhrases.txt | awk -F ' ' '{print $2}' | grep "狐藉虎威"
    CHECK_RESULT $?
    grep '傷亡枕藉' /tmp/TSPhrases.txt | grep '伤亡枕藉'
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}
function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE 1
    rm -rf /tmp/TSPhrases.txt
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
