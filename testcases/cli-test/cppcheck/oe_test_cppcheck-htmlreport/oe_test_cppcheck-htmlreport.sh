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
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/11/09
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of cppcheck-htmlreport command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL cppcheck
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cppcheck --xml file.c 2>err1.xml
    CHECK_RESULT $?
    grep -E "<?xml|<|>|arrayIndexOutOfBounds" err1.xml
    CHECK_RESULT $?
    cppcheck --enable=all --xml-version=2 file.c 2>err2.xml
    CHECK_RESULT $?
    grep -E "<?xml|<|>|arrayIndexOutOfBounds|unreadVariable|missingIncludeSystem" err2.xml
    CHECK_RESULT $?
    cppcheck-htmlreport --help | grep "Usage: cppcheck-htmlreport \[options\]"
    CHECK_RESULT $?
    cppcheck-htmlreport --title=fileReport --file=err1.xml --report-dir=testErr1 | grep -E "Parsing|Creating|Processing|file.c"
    CHECK_RESULT $?
    grep "fileReport" testErr1/index.html
    CHECK_RESULT $?
    cppcheck-htmlreport --title=fileReport2 --file=err2.xml --report-dir=testErr2 --source-dir=. | grep -E "Parsing|Creating|Processing|file.c"
    CHECK_RESULT $?
    grep "fileReport2" testErr2/index.html
    CHECK_RESULT $?
    cppcheck-htmlreport --title=fileReport3 --file=err2.xml --report-dir=testErr3 --source-encoding=UTF-8 | grep -E "Parsing|Creating|Processing|file.c"
    CHECK_RESULT $?
    grep "fileReport3" testErr3/index.html
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    roc=$(ls | grep -vE "\.sh|\.c")
    rm -rf $roc
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
