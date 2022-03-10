#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

###################################
#@Author    :   qinhaiqi
#@Contact   :   2683064908@qq.com
#@Date      :   2022/2/16
#@License   :   Mulan PSL v2
#@Desc      :   Test "paps" command
###################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL paps
    touch test.txt
    echo yes >>./test.txt
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run testcase."
    paps -h 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 0  "Failed option: -h"
    paps --landscape test.txt 2>&1 | grep "%%Orientation: Landscape"
    CHECK_RESULT $? 0 0 0  "Failed option: --landscape"
    paps --stretch-chars test.txt 2>&1 | grep "%%Title: test.txt"
    CHECK_RESULT $? 0 0 0  "Failed option: --stretch-chars"    
    paps --markup test.txt 2>&1 | grep "()paps_exec"
    CHECK_RESULT $? 0 0 0  "Failed option: --markup"
    paps --columns=1 test.txt 2>&1 | grep "1 setnumcolumns"
    CHECK_RESULT $? 0 0 0  "Failed option: --columns"
    paps --font=Monospace test.txt 2>&1 | grep "%%Title: test.txt"
    CHECK_RESULT $? 0 0 0  "Failed option: --font"
    paps --rtl test.txt 2>&1 | grep "%%Title: test.txt" 
    CHECK_RESULT $? 0 0 0  "Failed option: --rtl"
    paps --paper=a4 test.txt 2>&1 | grep "%%Title: test.txt"
    CHECK_RESULT $? 0 0 0  "Failed option: --paper"
    paps --bottom-margin=36 test.txt 2>&1 | grep "%%Title: test.txt"
    CHECK_RESULT $? 0 0 0  "Failed option: --bottom-margin" 
    paps --top-margin=36 test.txt 2>&1 | grep "/ytop 805"
    CHECK_RESULT $? 0 0 0  "Failed option: --top-margin"
    paps --right-margin=36 test.txt 2>&1 | grep "/column_width 523 def"
    CHECK_RESULT $? 0 0 0  "Failed option: --right-margin"
    paps --left-margin=36 test.txt 2>&1 | grep "/column_width 523 def"
    CHECK_RESULT $? 0 0 0  "Failed option: --left-margin"
    paps --header test.txt 2>&1 | grep "/ZAA { start_ol"
    CHECK_RESULT $? 0 0 0  "Failed option: --header"
    paps --encoding=utf8 test.txt 2>&1 | grep "%%Title: test.txt"
    CHECK_RESULT $? 0 0 0  "Failed option: --encoding"
    paps --lpi=1 test.txt 2>&1 | grep "%%Title: test.txt"
    CHECK_RESULT $? 0 0 0  "Failed option: --lpi"
    paps --cpi=1 test.txt 2>&1 | grep "%%Title: test.txt"
    CHECK_RESULT $? 0 0 0  "Failed option: --cpi"
    LOG_INFO "End to run testcase."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm test.txt 
    LOG_INFO "End to restore the test environment." 
}

main "$@"
