#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# ######################################################
# @Author    :   zhanglu626
# @Contact   :   m18409319968@163.com
# @Date      :   2022/01/17
# @License   :   Mulan PSL v2
# @Desc      :   A compiler written in Python for LESS
# ######################################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL python3-lesscpy
    mkdir less_zl
    echo "@color: #4D926F;

#header {
 color: @color;
}
h2 {
 color:@color;
}" >>less_zl/zl.less
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    lesscpy -h 2>&1 | grep "LessCss Compiler"
    CHECK_RESULT $? 0 0 "Help message is misprinted"
    lesscpy -v 2>&1 | grep "compiler"
    CHECK_RESULT $? 0 0 "version message is misprinted"
    lesscpy -V less_zl/zl.less 2>&1 | grep "Compiling target: less_zl/zl.less"
    CHECK_RESULT $? 0 0 "Description Failed to print the detailed mode"
    lesscpy -C less_zl/zl.less >less_zl/less_C 2>&1 && grep "Compiling target" less_zl/less_C
    CHECK_RESULT $? 1 0 "Failed to output file"
    lesscpy -x less_zl/zl.less 2>&1 | grep "#header{color:#4d926f;}"
    CHECK_RESULT $? 0 0 "Minimize output failure"
    lesscpy -X less_zl/zl.less 2>&1 | grep "#header{color:#4d926f;}h2{color:#4d926f;}"
    CHECK_RESULT $? 0 0 "Minimize output or Block a newline failure"
    lesscpy -t less_zl/zl.less 2>&1 | grep $'\t'"color"
    CHECK_RESULT $? 0 0 "Failed to use tabs"
    lesscpy -s 8 less_zl/zl.less 2>&1 | egrep "^ {8}"
    CHECK_RESULT $? 0 0 "Failed to specify 8 Spaces at the beginning"
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    DNF_REMOVE
    rm -rf less_zl
    LOG_INFO "Finish environment cleanup."
}

main $@
