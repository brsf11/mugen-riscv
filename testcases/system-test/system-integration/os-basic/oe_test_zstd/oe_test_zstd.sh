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
# @Author    :   liuyafei1
# @Contact   :   liuyafei@uniontech.com
# @Date      :   2022-12-21
# @License   :   Mulan PSL v2
# @Desc      :   function verification
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8 
    DNF_INSTALL zstd
    echo "aaa" >file1
    echo "bbb" >file2   
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    zstd file1
    test -e file1.zst
    CHECK_RESULT $? 0 0  "The file1 is not exit"
    zstd --rm -rf file2
    CHECK_RESULT $? 0 0  "file2 result fail"
    zstd  -d  file2.zst
    test -e file2
    CHECK_RESULT $? 0 0 "check file2's help manual fail"
    zstdcat file1.zst |grep aaa
    CHECK_RESULT $? 0 0 "check file1's help manual fail"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    export LANG=${OLD_LANG}
    rm -rf file1  file1.zst  file2  file2.zst
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"



