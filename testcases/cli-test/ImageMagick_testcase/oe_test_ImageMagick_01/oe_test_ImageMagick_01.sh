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
    convert test2.jpg test2.png
    CHECK_RESULT $?
    test -f test2.png
    CHECK_RESULT $?
    convert test2.png test2.bmp
    CHECK_RESULT $?
    test -f test2.bmp
    CHECK_RESULT $?
    convert test2.bmp test2.gif
    CHECK_RESULT $?
    test -f test2.gif
    CHECK_RESULT $?
    convert test2.gif test2.tiff
    CHECK_RESULT $?
    test -f test2.tiff
    CHECK_RESULT $?
    convert test2.tiff test2.pcx
    CHECK_RESULT $?
    test -f test2.pcx
    CHECK_RESULT $?
    convert -sample 50%x50% test1.jpg test1_sj.jpg
    CHECK_RESULT $?
    test -f test1_sj.jpg
    CHECK_RESULT $?
    convert -resize 1024x576 test1_sj.jpg test1_tz.jpg
    CHECK_RESULT $?
    test -f test1_tz.jpg
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
