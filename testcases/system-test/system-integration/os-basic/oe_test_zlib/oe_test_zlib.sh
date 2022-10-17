#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   fuyh2020
# @Contact   :   fuyahong@uniontech.com
# @Date      :   2020-09-19
# @License   :   Mulan PSL v2
# @Desc      :   Command test zlib
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "zlib zlib-devel gcc"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    gcc -Wall -o test test.c -lz
    CHECK_RESULT $? 0 0 "compile file error"
    ./test | grep -E "Src string:hello world! aaaaa bbbbb ccccc ddddd|UnCompressed String:hello world! aaaaa bbbbb ccccc ddddd"
    CHECK_RESULT $? 0 0 "grep msg error"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf test
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
