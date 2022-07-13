#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ##############################################
# @Author    :   blackgaryc
# @Contact   :   blackgaryc@gmail.com
# @Date      :   2022-06-10
# @License   :   Mulan PSL v2
# @Desc      :   Test xdelta
# ##############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL "xdelta vim-common"
    echo aabbcc > input
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start to run test."
    # standard options
    xdelta3 -e input output
    xxd -p -c1280 output | grep 'd6c3c400050206696e7075742f041107000701000a5f02576161626263630a08'
    CHECK_RESULT $? 0 0 "test failed with -e"
    xdelta3 -0 oe_test_xdelta_001.sh | xxd -p > xxd0
    xdelta3 -9 oe_test_xdelta_001.sh | xxd -p > xxd9
    test $(wc -c xxd9 | awk '{print($1)}') -ge $(wc -c xxd0 | awk '{print($1)}')
    CHECK_RESULT $? 0 0 "test failed with -0..9"
    xdelta3 -d output input_d
    grep "aabbcc" input_d
    CHECK_RESULT $? 0 0 "test failed with -d"
    xdelta3 -c input | xxd -p -c1280 | grep 'd6c3c400050206696e7075742f041107000701000a5f02576161626263630a08'
    CHECK_RESULT $? 0 0 "test failed with -c"
    xdelta3 -f input output && xxd -p -c1280 output | grep 'd6c3c400050206696e7075742f041107000701000a5f02576161626263630a08'
    CHECK_RESULT $? 0 0 "test failed with -f"
    xdelta -F input 2>&1 | grep -a 'xdelta3: finished'
    CHECK_RESULT $? 0 0 "test failed with -F"
    xdelta3 -h 2>&1 | grep 'usage: xdelta3'
    CHECK_RESULT $? 0 0 "test failed with -h"
    # file fileinput is not exist, command will throw error message
    # using -q means not display error message
    # this command shouled return 1
    xdelta3 -q file_should_not_exist 2>&1 | grep 'xdelta3: file open failed'
    CHECK_RESULT $? 1 0 "test failed with -q"
    xdelta3 -v input 2>&1 | grep -a finished
    CHECK_RESULT $? 0 0 "test failed with -v"
    xdelta3 -V 2>&1 | grep -i "xdelta version"
    CHECK_RESULT $? 0 0 "test failed with -V"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf input* output* xxd*
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
