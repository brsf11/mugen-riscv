#!/usr/bin/bash

# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   chengweibin
# @Contact   :   chengweibin@uniontech.com
# @Date      :   2021-08-03
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-rm
# ############################################
source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test(){
    LOG_INFO "Start to run test."

    touch /tmp/test
    CHECK_RESULT $? 0 0 "File creation failed"
    mkdir /tmp/test1
    CHECK_RESULT $? 0 0 "Directory creation failed"
    rm -rf /tmp/test
    CHECK_RESULT $? 0 0 "Failed to delete files"
    rm -rf /tmp/test1
    CHECK_RESULT $? 0 0 "Failed to delete directory"
    rm --help
    CHECK_RESULT $? 0 0 "rm --help failed"

    LOG_INFO "End to run test."
}

main $@