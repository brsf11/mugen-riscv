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
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start to run test."
    optipng -help |grep "Synopsis"
    CHECK_RESULT $? 0 0 "Help information printing failed"
    optipng -v |grep -E "version"
    CHECK_RESULT $? 0 0 "Version information printing failed"
    cp ../common/ini.png test.png
    CHECK_RESULT $?
    optipng test.png -log test.log
    CHECK_RESULT $?
    ls |grep test.log 
    CHECK_RESULT $? 0 0 "Failed to output the log file"    
    cp ../common/ini.png test1.png
    CHECK_RESULT $?
    optipng -o1 test1.png -log test1.log
    CHECK_RESULT $?
    grep -i "output" test1.log
    CHECK_RESULT $? 0 0 "Failed to set the level"
    cp ../common/ini.png test2.png
    CHECK_RESULT $?
    optipng -backup test2.png
    CHECK_RESULT $? 
    ls |grep test2.png.bak
    CHECK_RESULT $? 0 0 "Failed to back up files"
    optipng -clobber test2.png.bak -log test2a.log
    CHECK_RESULT $?
    grep -i "output" test2a.log
    CHECK_RESULT $? 0 0 "Overwrite file failed"
    cp ../common/ini.png test3.png
    CHECK_RESULT $?
    optipng test3.png
    CHECK_RESULT $?
    optipng -force test3.png -log test3.log
    CHECK_RESULT $?
    grep -i "output" test3.log
    CHECK_RESULT $? 0 0 "Force run failure"
    cp ../common/ini.png test4.png
    CHECK_RESULT $?
    optipng -preserve test4.png -log test4.log
    CHECK_RESULT $?
    grep -i "output" test4.log
    CHECK_RESULT $? 0 0 "Failure to retain properties"
    cp ../common/ini.png test5.png
    CHECK_RESULT $?
    optipng -quiet test5.png 
    CHECK_RESULT $? 0 0 "Silent run failure"
    cp ../common/ini.png test6.png
    CHECK_RESULT $?
    optipng -simulate test6.png -log test6.log
    CHECK_RESULT $?
    grep -i "simulation mode" test6.log
    CHECK_RESULT $? 0 0 "Simulation run failure"
    cp ../common/ini.png test7.png
    CHECK_RESULT $?
    optipng test7.png -out test7.gif
    CHECK_RESULT $?
    ls |grep test7.gif
    CHECK_RESULT $? 0 0 "Failed to output file"
    cp ../common/ini.png test8.png
    CHECK_RESULT $?
    optipng test8.png -dir ./
    CHECK_RESULT $?
    ls |grep test8.png
    CHECK_RESULT $? 0 0 "Failed to specify path"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf $(ls | grep -v ".sh")
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main $@
