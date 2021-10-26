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
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start to run test."
    cp ../common/ini.png test9.png
    CHECK_RESULT $?
    optipng -f 2 test9.png -log test9.log
    CHECK_RESULT $?
    grep -i "f = 2" test9.log
    CHECK_RESULT $? 0 0 "Filter failure"
    cp ../common/ini.png test10.png
    CHECK_RESULT $?
    optipng -i 1 test10.png -log test10a.log
    CHECK_RESULT $?
    grep -i "output" test10a.log
    CHECK_RESULT $? 0 0 "Interlaced scan failed"
    optipng -i 0 test10.png -log test10b.log
    CHECK_RESULT $?
    grep -iE "output|interlaced" test10a.log
    CHECK_RESULT $? 0 0 "Non-interlaced scan failed"
    cp ../common/ini.png test11.png
    CHECK_RESULT $?
    optipng -zc 6 -zm 4 -zs 1 -zw 4k test11.png -log test11.log
    CHECK_RESULT $?
    grep -iE "output|zc = 6|zm = 4|zs = 1" test11.log
    CHECK_RESULT $? 0 0 "Failed to set zlib"
    cp ../common/ini.png test12.png
    CHECK_RESULT $?
    optipng -full test12.png -log test12.log
    CHECK_RESULT $?
    grep -iE "output|IDAT size" test12.log
    CHECK_RESULT $? 0 0 "Report printing failed"
    cp ../common/ini.png test13.png
    CHECK_RESULT $?
    optipng -nb -nc -np -nx test13.png -log test13.log
    CHECK_RESULT $?
    grep -i "output" test13.log
    CHECK_RESULT $? 0 0 "Failed to set nb or nc or np or nx"
    cp ../common/ini.png test14.png
    CHECK_RESULT $?
    optipng -nz test14.png -log test14.log
    CHECK_RESULT $?
    grep -i "trying" test14.log
    CHECK_RESULT $? 1 0 "Failed to set nz"
    cp ../common/ini.png test15.png
    CHECK_RESULT $?
    optipng -strip all test15.png -log test15.log
    CHECK_RESULT $?
    grep -iE "output|Stripping metadata" test15.log
    CHECK_RESULT $? 0 0 "Failed to delete metadata"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf $(ls | grep -v ".sh")
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main $@
