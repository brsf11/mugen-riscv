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
# @Date      :   2022-11-08
# @License   :   Mulan PSL v2
# @Desc      :   Command sdiff  
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
    echo -e "aaa\nccc" >file2
    sdiff file1 file2 | grep ccc
    CHECK_RESULT $? 0 0 "The file content is abnormal "
    sdiff -s file1 file2 | sed -e 's#>[[:space:]]##g' -e 's/^[[:space:]]*//g' >sdiff.log
    test -f sdiff.log
    CHECK_RESULT $? 0 0 "The diff.log is not exit "
    grep ccc sdiff.log
    CHECK_RESULT $? 0 0 "The diff.log  is abnormal"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    export LANG=${OLD_LANG}
    DNF_REMOVE
    rm -rf file1 file2 sdiff.log
    LOG_INFO "End to restore the test environment."
}

main $@

