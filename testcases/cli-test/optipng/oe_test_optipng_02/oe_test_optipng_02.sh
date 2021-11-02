#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ###############################################
# @Author    :   suhang
# @Contact   :   suhangself@163.com
# @Date      :   2021-08-09
# @License   :   Mulan PSL v2
# @Desc      :   Image compression tool optiPNG
# ##############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL optipng
    for i in {1..7}; do
        cp ../common/ini.png test"$i".png
    done
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start to run test."
    optipng -f 2 test1.png -log test1.log
    CHECK_RESULT $?
    grep "f = 2" test1.log
    CHECK_RESULT $? 0 0 "Filter failure"
    optipng -i 1 test2.png -log test2a.log
    CHECK_RESULT $?
    grep "Output" test2a.log
    CHECK_RESULT $? 0 0 "Interlaced scan failed"
    optipng -i 0 test2.png -log test2b.log
    CHECK_RESULT $?
    grep -E "Output|interlaced" test2a.log
    CHECK_RESULT $? 0 0 "Non-interlaced scan failed"
    optipng -zc 6 -zm 4 -zs 1 -zw 4k test3.png -log test3.log
    CHECK_RESULT $?
    grep -E "Output|zc = 6|zm = 4|zs = 1" test3.log
    CHECK_RESULT $? 0 0 "Failed to set zlib"
    optipng -full test4.png -log test4.log
    CHECK_RESULT $?
    grep -E "Output|IDAT size" test4.log
    CHECK_RESULT $? 0 0 "Report printing failed"
    optipng -nb -nc -np -nx test5.png -log test5.log
    CHECK_RESULT $?
    grep "Output" test5.log
    CHECK_RESULT $? 0 0 "Failed to set nb or nc or np or nx"
    optipng -nz test6.png -log test6.log
    CHECK_RESULT $?
    grep "trying" test6.log
    CHECK_RESULT $? 1 0 "Failed to set nz"
    optipng -strip all test7.png -log test7.log
    CHECK_RESULT $?
    grep -E "Output|Stripping metadata" test7.log
    CHECK_RESULT $? 0 0 "Failed to delete metadata"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf ./test*
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
