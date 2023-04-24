#!/usr/bin/bash

# Copyright (c) 2023 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   wulei
# @Contact   :   wulei@uniontech.com
# @Date      :   2023.2.2
# @License   :   Mulan PSL v2
# @Desc      :   vim command test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    file="test.file"
    echo 'Hello Word!' > ${file}
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    vim -N -u NONE -n -S update_file.vim ${file}
    grep 'UOS' ${file}
    CHECK_RESULT $? 0 0 "Failed to modify the file"
    vim -N -u NONE -n -S del_file.vim ${file}
    grep 'UOS' ${file}
    CHECK_RESULT $? 0 1 "Failed to delete the file"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf ${file}
    LOG_INFO "End to restore the test environment."
}
main $@
