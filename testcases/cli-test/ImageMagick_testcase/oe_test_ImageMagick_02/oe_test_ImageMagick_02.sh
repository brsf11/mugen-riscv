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
    convert -resize 900x600 -quality 70 -strip test3.jpg thumbnail.jpg
    CHECK_RESULT "$(identify -verbose thumbnail.jpg | grep Quality | grep -cE '70')" 1
    convert -resize 900x600 -quality 100 -strip test3.jpg thumbnail1.jpg
    CHECK_RESULT "$(identify -verbose thumbnail1.jpg | grep Quality | grep -cE '100')" 1
    convert -resize 900x600 -quality 101 -strip test3.jpg thumbnail2.jpg
    CHECK_RESULT "$(identify -verbose thumbnail2.jpg | grep Quality | grep -cE '100')" 1
    convert -resize 900x600 -quality -1 -strip test3.jpg thumbnail3.jpg
    CHECK_RESULT "$(identify -verbose thumbnail3.jpg | grep Quality | grep -cE '100')" 1
    convert -resize '150x100!' test1.jpg suof1.jpg
    CHECK_RESULT $?
    test -f suof1.jpg
    CHECK_RESULT $?
    convert -resize '150x100>' test2.jpg suof2.jpg
    CHECK_RESULT $?
    test -f suof2.jpg
    CHECK_RESULT $?
    convert -resize '150x100<' test3.jpg suof3.jpg
    CHECK_RESULT $?
    test -f suof3.jpg
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
