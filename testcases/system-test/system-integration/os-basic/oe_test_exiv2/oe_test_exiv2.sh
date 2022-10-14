#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   fuyh2020
# @Contact   :   fuyahong@uniontech.com
# @Date      :   2022-09-19
# @License   :   Mulan PSL v2
# @Desc      :   Command test exiv2
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL exiv2
    LOG_INFO "End of environmental preparation!"

}

function run_test() {
    LOG_INFO "Start to run test."

    exiv2 test.jpg > tmp.1 
    CHECK_RESULT $? 0 0 "view image info error"

    exiv2 -pa test.jpg > tmp.2
    CHECK_RESULT $? 0 0 "view image details info error before add"

    cat tmp.2   
    grep "Iptc.Application2.Credit                     String      9  Mr. Smith" tmp.2
    CHECK_RESULT $? 1 0 "query image info before add"

    cp test.jpg test1.jpg
    exiv2 -M "add Iptc.Application2.Credit String Mr. Smith" test1.jpg
    CHECK_RESULT $? 0 0 "add image info error"

    exiv2 -pa test1.jpg > tmp.3
    CHECK_RESULT $? 0 0 "view image details info error after add"
    grep "Iptc.Application2.Credit                     String      9  Mr. Smith" tmp.3
    CHECK_RESULT $? 0 0 "query image info error after add"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -f  tmp.* test1.jpg
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"

}
main "$@"
