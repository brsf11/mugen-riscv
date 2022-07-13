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
    id -u xdelta_testuser
    if [ $? -eq 1 ];then
        useradd xdelta_testuser
    fi
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start to run test."
    # special command names
    # config
    # print xdelta3 config
    xdelta3 config 2>&1 | grep 'XD3.*=[0-9]*'
    CHECK_RESULT $? 0 0 "test failed on config"
    # encode
    # encode data "aabbcc" save as output.vcdiff
    echo aabbcc | xdelta3 encode > output.vcdiff
    xxd -p -c1280 output.vcdiff | grep "d6c3c4000502022d2f041107000701000a5f02576161626263630a08"
    CHECK_RESULT $? 0 0 "test failed on encode"
    # decode
    # decode file output.vcdiff, print string aabbcc on success 
    xdelta3 decode <output.vcdiff | grep aabbcc
    CHECK_RESULT $? 0 0 "test failed on decode"
    # test
    su xdelta_testuser -c '/usr/bin/xdelta3 test'
    CHECK_RESULT $? 0 0 "test failed on test"
    # special commands for VCDIFF inputs
    # printdelta
    xdelta3 printdelta output.vcdiff | grep 'VCDIFF.*'
    CHECK_RESULT $? 0 0 "test failed on printdelta"
    # printhdr
    xdelta3 printhdr output.vcdiff | grep -i vcdiff
    CHECK_RESULT $? 0 0 "test failed on printhdr"
    # printhdrs
    xdelta3 printhdrs output.vcdiff | grep -i vcdiff
    CHECK_RESULT $? 0 0 "test failed on printhdrs"
    # recode
    # try to encode vcdiff file using djw1
    xdelta3 recode -S djw1 output.vcdiff | xxd -p -c1280 | grep "d6c3c4000501022d2f041107000701000a5f02576161626263630a08"
    CHECK_RESULT $? 0 0 "test failed on recode"
    # merge
    # merge multiple vcdiff file, using -m to add more files
    # -m will test in other file
    xdelta3 merge output.vcdiff output-merged.vcdiff
    xxd -p -c1280 output-merged.vcdiff | grep "d6c3c4000102041107000701000a5f02576161626263630a08"
    CHECK_RESULT $? 0 0 "test failed on merge"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf output* xdelta*
    userdel -rf xdelta_testuser
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
