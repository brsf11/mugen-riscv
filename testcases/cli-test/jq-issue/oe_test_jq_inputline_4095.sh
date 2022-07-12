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
# @Date      :   2021/02/04
# @License   :   Mulan PSL v2
# @Desc      :   Print lines with a length of 4095 multiples
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL jq
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    echo '1
1
3' >/tmp/diff_result
    python3 -c "print('0\n\"' + 'a'*4093 + '\"\n0');" | jq 'input_line_number' >/tmp/jq_4095_result
    diff /tmp/diff_result /tmp/jq_4095_result
    CHECK_RESULT $?
    python3 -c "print('0\n\"' + 'a'*16378 + '\"\n0');" | jq 'input_line_number' >/tmp/jq_16380_result
    diff /tmp/diff_result /tmp/jq_16380_result
    CHECK_RESULT $?

}
function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf /tmp/diff_result /tmp/jq_16380_result /tmp/jq_4095_result
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
