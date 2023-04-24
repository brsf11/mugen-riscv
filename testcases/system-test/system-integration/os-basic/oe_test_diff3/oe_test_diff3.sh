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
# @Date      :   2022-11-25
# @License   :   Mulan PSL v2
# @Desc      :   diff3 function verification  
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    DNF_INSTALL diffutils
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start testing..."
    echo "aaa" >file1
    echo "aab" >file2
    echo "aac" >file3
    diff3 file1 file2 file3 >diff3.log
    test -f diff3.log
    CHECK_RESULT $? 0 0 "The diff3.log is not exit "
    diff3_value1= $(cat diff3.log |sed -n '1,7p')
    diff3_value2= $(cat diff3.log |awk '{print$1}')
    CHECK_RESULT $((diff3_value1)) $((diff3_value2)) 0 "diff3's result fail"
    diff3  -A file1 file2 file3 |grep 0a
    CHECK_RESULT $? 0 0 "The relust is abnormal"
    diff3 --help | grep "Usage: diff3"
    CHECK_RESULT $? 0 0 "The file content is abnormal "
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    export LANG=${OLD_LANG}
    DNF_REMOVE
    rm -rf file1 file2 file3 diff3.log
    LOG_INFO "End to restore the test environment."
}

main $@


