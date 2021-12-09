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
# @Author    :   lutianxiong
# @Contact   :   lutianxiong@huawei.com
# @Date      :   2021-01-10
# @License   :   Mulan PSL v2
# @Desc      :   lzo test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
origin_file="/etc/os-release"

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL lzop
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    lzop -o test.lzo $origin_file
    diff test.lzo $origin_file
    CHECK_RESULT $? 0 1
    lzop -t test.lzo
    CHECK_RESULT $?
    lzop -l test.lzo
    CHECK_RESULT $?
    lzop -d test.lzo
    CHECK_RESULT $?
    diff test $origin_file
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf test test.lzo
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main $@
