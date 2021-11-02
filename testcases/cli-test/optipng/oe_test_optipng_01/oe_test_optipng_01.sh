#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ##############################################
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
    for i in {0..8}; do
        cp ../common/ini.png test"$i".png
    done
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start to run test."
    optipng -help | grep "Synopsis"
    CHECK_RESULT $? 0 0 "Help information printing failed"
    optipng -v | grep -E "[0-9]"
    CHECK_RESULT $? 0 0 "Version information printing failed"
    optipng test0.png -log test0.log
    CHECK_RESULT $?
    test -f test0.log
    CHECK_RESULT $? 0 0 "Failed to output the log file"
    optipng -o1 test1.png -log test1.log
    CHECK_RESULT $?
    grep "Output" test1.log
    CHECK_RESULT $? 0 0 "Failed to set the level"
    optipng -backup test2.png
    CHECK_RESULT $?
    test -f test2.png.bak
    CHECK_RESULT $? 0 0 "Failed to back up files"
    optipng -clobber test2.png.bak -log test2a.log
    CHECK_RESULT $?
    grep "Output" test2a.log
    CHECK_RESULT $? 0 0 "Overwrite file failed"
    optipng test3.png
    CHECK_RESULT $?
    optipng -force test3.png -log test3.log
    CHECK_RESULT $?
    grep "Output" test3.log
    CHECK_RESULT $? 0 0 "Force run failure"
    optipng -preserve test4.png -log test4.log
    CHECK_RESULT $?
    grep "Output" test4.log
    CHECK_RESULT $? 0 0 "Failure to retain properties"
    optipng -quiet test5.png
    CHECK_RESULT $? 0 0 "Silent run failure"
    optipng -simulate test6.png -log test6.log
    CHECK_RESULT $?
    grep "simulation mode" test6.log
    CHECK_RESULT $? 0 0 "Simulation run failure"
    optipng test7.png -out test7.gif
    CHECK_RESULT $?
    test -f test7.gif
    CHECK_RESULT $? 0 0 "Failed to output file"
    optipng test8.png -dir /tmp/
    CHECK_RESULT $?
    test -f /tmp/test8.png
    CHECK_RESULT $? 0 0 "Failed to specify path"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf ./test* /tmp/test8.png
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
