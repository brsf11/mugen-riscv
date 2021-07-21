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
function pre_test()
{
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL ImageMagick
    LOG_INFO "End to prepare the test environment."
}
function run_test()
{
    LOG_INFO "Start to run test." 
    cp -r ../common ../common1
    cd ../common1
    mogrify -resize 50% test1.jpg
    test -f test1.jpg
    CHECK_RESULT $?
    mogrify -resize 256x256 *.jpg
    CHECK_RESULT $?
    convert test2.jpg test2.png
    mogrify -format jpg *.png
    CHECK_RESULT $?
    identify test1.jpg
    CHECK_RESULT $?
    identify -verbose  test1.jpg
    CHECK_RESULT $?
    identify -depth 8 -size 900x518 test1.jpg
    CHECK_RESULT $?
    identify -verbose -features 1 -moments -unique test1.jpg
    CHECK_RESULT $?
    CHECK_RESULT "$(identify -precision 5 -define identify:locate=maximum -define identify:limit=3 test1.jpg | grep -cE 'Red|Green|Blue')" 3
    LOG_INFO "End to run test."
}
function post_test()
{
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ../common1
    LOG_INFO "End to restore the test environment."
}
main "$@"
