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
    local_path=${OET_PATH}/testcases/ImageMagick_testcase
    LOG_INFO "End to prepare the test environment."
}
function run_test()
{
    LOG_INFO "Start to run test." 
    cd $local_path/
    SLEEP_WAIT 2
    cp -r common common1
    SLEEP_WAIT 2
    cd common1
    composite -gravity southeast test1.jpg test3.jpg des2.jpg
    CHECK_RESULT $?
    composite -gravity center test1.jpg test3.jpg des1.jpg
    CHECK_RESULT $?
    composite test1.jpg -resize 200% -compose bumpmap -gravity southwest test2.jpg z.jpg
    SLEEP_WAIT 5
    CHECK_RESULT "$(ls | grep -cE 'z.jpg')" 1
    composite -compose multiply -gravity Center -geometry +70-5 test1.jpg test2.jpg z1.jpg
    SLEEP_WAIT 5
    CHECK_RESULT "$(ls | grep -cE 'z1.jpg')" 1
    composite -watermark 30% -gravity south test1.jpg test2.jpg z2.jpg
    SLEEP_WAIT 5
    CHECK_RESULT "$(ls | grep -cE 'z2.jpg')" 1
    composite label:Center -gravity center test2.jpg z3.jpg
    SLEEP_WAIT 5
    CHECK_RESULT "$(ls | grep -cE 'z3.jpg')" 1
    compare -verbose -metric mae test2.jpg test2.jpg difference.png
    CHECK_RESULT "$(ls | grep -cE 'difference.png')" 1
    compare -channel red -metric PSNR test3.jpg test2.jpg difference1.png
    CHECK_RESULT "$(ls | grep -cE 'difference1.png')" 1
    compare -metric PSNR test2.jpg test3.jpg difference2.png
    CHECK_RESULT "$(ls | grep -cE 'difference2.png')" 1
    LOG_INFO "End to run test."
}
function post_test()
{
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf $local_path/common1
    LOG_INFO "End to restore the test environment."
}
main "$@"
