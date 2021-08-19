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
# @Date      :   2020/5/27
# @License   :   Mulan PSL v2
# @Desc      :   Working with empty linked files
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    ls ${test_txt} && rm -rf ${test_txt}
    ls test1.txt && rm -rf test1.txt
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    test_txt=$(mktemp)
    ls -l ${test_txt}
    CHECK_RESULT $? 0 0 "mktemp failed"
    ln -s ${test_txt} test1.txt
    ls -l | grep "test1.txt -> ${test_txt}"
    CHECK_RESULT $?
    rm -rf ${test_txt}
    ls -l ${test_txt} 2>&1 | grep "No such file or directory"
    CHECK_RESULT $?
    find ./ -type l -follow 2>/dev/null | grep test1.txt
    CHECK_RESULT $?
    rm -rf test1.txt
    ls -l | grep "test1.txt -> ${test_txt}"
    CHECK_RESULT $? 0 1
    test_txt=$(mktemp)
    ln ${test_txt} /tmp/test2.txt
    CHECK_RESULT $?
    CHECK_RESULT $(ls -li ${test_txt} | awk -F' ' '{print $1}') $(ls -li /tmp/test2.txt | awk -F' ' '{print $1}')
    LOG_INFO "Finish testcase execution."
}
function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /tmp/test2.txt test1.txt ${test_txt}
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
