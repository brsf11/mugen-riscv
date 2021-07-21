#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   guochenyang_wx5323712
#@Contact   	:   lemon.higgins@aliyun.com
#@Date      	:   2020-10-10 09:30:43
#@License   	:
#@Version   	:   1.0
#@Desc      	:   verification ImageMagick‘s command
#####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ImageMagick
    cp -r ../common ../common1
    cd ../common1
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    composite -gravity southeast test1.jpg test3.jpg des2.jpg
    CHECK_RESULT $?
    test -f des2.jpg
    CHECK_RESULT $?
    composite -gravity center test1.jpg test3.jpg des1.jpg
    CHECK_RESULT $?
    test -f des1.jpg
    CHECK_RESULT $?
    composite test1.jpg -resize 200% -compose bumpmap -gravity southwest test2.jpg z.jpg
    SLEEP_WAIT 5
    CHECK_RESULT $?
    test -f z.jpg
    CHECK_RESULT $?
    composite -compose multiply -gravity Center -geometry +70-5 test1.jpg test2.jpg z1.jpg
    SLEEP_WAIT 5
    CHECK_RESULT $?
    test -f z1.jpg
    CHECK_RESULT $?
    composite -watermark 30% -gravity south test1.jpg test2.jpg z2.jpg
    CHECK_RESULT $?
    test -f z2.jpg
    CHECK_RESULT $?
    composite label:Center -gravity center test2.jpg z3.jpg
    SLEEP_WAIT 5
    CHECK_RESULT $?
    test -f z3.jpg
    CHECK_RESULT $?
    compare -verbose -metric mae test2.jpg test2.jpg difference.png
    CHECK_RESULT $?
    test -f difference.png
    CHECK_RESULT $?
    compare -channel red -metric mae test3.jpg test3.jpg difference1.png
    CHECK_RESULT $?
    test -f difference1.png
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}
function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ../common1
    LOG_INFO "End to restore the test environment."
}
main "$@"
