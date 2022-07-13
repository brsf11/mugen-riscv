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
    echo filetest1 > input1
    echo filetest2 > input2
    xdelta3 input1 output.1.vcdiff
    xdelta3 input2 output.2.vcdiff
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start to run test."
    # memory options
    xdelta3 -B 1024000 input1 | xxd -p -c1280 | grep 'd6c3c400050207696e707574312f04300a01260100161f039c0afd377a585a000000ff12d941020021010c0000008f98419c01000966696c6574657374310a0b'
    CHECK_RESULT $? 0 0 "failed to test -B"
    xdelta3 -W 20480 input1 | xxd -p -c1280 | grep 'd6c3c400050207696e707574312f04300a01260100161f039c0afd377a585a000000ff12d941020021010c0000008f98419c01000966696c6574657374310a0b'
    CHECK_RESULT $? 0 0 "failed to test -W"
    xdelta3 -P 0 input1 | xxd -p -c1280 | grep 'd6c3c400050207696e707574312f04300a01260100161f039c0afd377a585a000000ff12d941020021010c0000008f98419c01000966696c6574657374310a0b'
    CHECK_RESULT $? 0 0 "failed to test -P"
    xdelta3 -I 0 input1 | xxd -p -c1280 | grep 'd6c3c400050207696e707574312f04300a01260100161f039c0afd377a585a000000ff12d941020021010c0000008f98419c01000966696c6574657374310a0b'
    CHECK_RESULT $? 0 0 "failed to test -I"
    # compression options:
    xdelta3 -s input1 input2 | xxd -p -c1280 | grep 'd6c3c40005020f696e707574322f2f696e707574312f0508000e0a000202011621039d320a180300'
    CHECK_RESULT $? 0 0 "failed to test -s"
    xdelta3 -S djw input1 | xxd -p -c1280 | grep 'd6c3c400050107696e707574312f04140a000a0100161f039c66696c6574657374310a0b'
    CHECK_RESULT $? 0 0 "failed to test -S"
    # disable small string-matching 
    xdelta3 -N -s input1 input2 | xxd -p -c1280 | grep 'd6c3c40005020f696e707574322f2f696e707574312f0508000e0a000202011621039d320a180300'
    CHECK_RESULT $? 0 0 "failed to test -N"
    xdelta3 -D input1 | xxd -p -c1280 | grep 'd6c3c400050207696e707574312f04300a01260100161f039c0afd377a585a000000ff12d941020021010c0000008f98419c01000966696c6574657374310a0b'
    CHECK_RESULT $? 0 0 "failed to test -D"
    xdelta3 -R -d -f output.1.vcdiff input_recover
    grep 'filetest1' input_recover
    CHECK_RESULT $? 0 0 "failed to test -R"
    xdelta3 -n input1 | xxd -p -c1280 | grep 'd6c3c400050207696e707574312f002c0a012601000afd377a585a000000ff12d941020021010c0000008f98419c01000966696c6574657374310a0b'
    CHECK_RESULT $? 0 0 "failed to test -n"
    xdelta3 -C 4,1,4,3,4,5,6 input1 | xxd -p -c1280 | grep 'd6c3c400050207696e707574312f04300a01260100161f039c0afd377a585a000000ff12d941020021010c0000008f98419c01000966696c6574657374310a0b'
    CHECK_RESULT $? 0 0 "failed to test -C"
    xdelta3 -A head input1 | xxd -p -c1280 | grep 'd6c3c4000502046865616404300a01260100161f039c0afd377a585a000000ff12d941020021010c0000008f98419c01000966696c6574657374310a0b'
    CHECK_RESULT $? 0 0 "failed to test -A"
    xdelta3 -J input1 2>&1 | grep -a 'filetest1'
    CHECK_RESULT $? 1 0 "failed to test -J"
    xdelta3 merge -m output.1.vcdiff output.2.vcdiff | xxd -p -c1280 | grep 'd6c3c400010204300a012601001621039d0afd377a585a000000ff12d941020021010c0000008f98419c01000966696c6574657374320a0b'
    CHECK_RESULT $? 0 0 "failed to test -m"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf input* output*
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
