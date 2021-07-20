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
    convert test1.jpg -region 127x650+1070+150 -resize 120% -fill "#eae4ba" -colorize 100% result.jpg
    CHECK_RESULT $?
    convert -rotate 270 test3.jpg test3-final.jpg 
    CHECK_RESULT $?
    convert -fill black -pointsize 60 -font helvetica -draw 'text 100,800 "hello"' test3.jpg hello.jpg
    CHECK_RESULT $?
    convert -flip test1.jpg bar.jpg
    CHECK_RESULT $?
    convert -flop test1.jpg bar1.jpg
    CHECK_RESULT $?
    convert -negate test1.jpg bar2.jpg
    CHECK_RESULT $?
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
