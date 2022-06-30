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
# @Date      :   2021/01/18
# @License   :   Mulan PSL v2
# @Desc      :   Adding simplified Chinese characters to complex Chinese characters in the dictionary HKVariantsRev
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL opencc
    cp /usr/share/opencc/HKVariantsRev.ocd2 /usr/share/opencc/HKVariantsRev.ocd2-bak
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    opencc_dict -i /usr/share/opencc/HKVariantsRev.ocd2 -o /tmp/HKVariantsRev.txt-old -f ocd2 -t ocd2
    CHECK_RESULT $?
    test -f /tmp/HKVariantsRev.txt-old
    CHECK_RESULT $?
    sed -i 's/臺/臺\ 台/g' /tmp/HKVariantsRev.txt-old
    sed -i 's/纔/才\ 纔/g' /tmp/HKVariantsRev.txt-old
    opencc_dict -i /tmp/HKVariantsRev.txt-old -o /usr/share/opencc/HKVariantsRev.ocd2 -f ocd2 -t ocd2
    CHECK_RESULT $?
    echo "臺" | opencc -c hk2s | opencc -c s2hk | grep '台'
    CHECK_RESULT $?
    echo "台" | opencc -c hk2s | opencc -c s2hk | grep '台'
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}
function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE 1
    rm -rf /tmp/HKVariantsRev.txt-old
    cp /usr/share/opencc/HKVariantsRev.ocd2-bak /usr/share/opencc/HKVariantsRev.ocd2
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
