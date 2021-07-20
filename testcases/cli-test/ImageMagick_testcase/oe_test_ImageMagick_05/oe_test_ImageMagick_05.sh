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
    cp -r common common1
    cd common1
    convert -crop 300x400+10+10 test1.jpg dest.jpg
    CHECK_RESULT $?
    convert test2.jpg -gravity center -crop 100x80+0+0 dest.jpg
    CHECK_RESULT $?
    convert test2.jpg -gravity southeast -crop 100x80+10+5 dest.jpg
    CHECK_RESULT $?
    convert test1.jpg -crop 100x100 destxt.jpg 
    CHECK_RESULT $?
    convert -mattecolor " #2E8B57" -frame 60x60 test1.jpg biankuang.png
    CHECK_RESULT $?
    convert -border 60x60 -bordercolor " #FF1493" test2.jpg biankuang1.jpg
    CHECK_RESULT $?
    convert -draw 'text 0,0"JD.COM"' -fill 'rgba(221,34,17,0.25)' -pointsize 36 -gravity center  test2.jpg  watermark.jpg
    CHECK_RESULT $?
    convert  -size 100x100  xc:none  -fill '#d90f02'  -pointsize 18 -gravity center  -draw 'rotate -45 text 0,0 "JD.COM"' -resize 60%  miff:-  |  composite  -tile  -dissolve 25  -  test3.jpg  watermark1.jpg
    CHECK_RESULT $?
    composite -gravity north test1.jpg test3.jpg des.jpg
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
