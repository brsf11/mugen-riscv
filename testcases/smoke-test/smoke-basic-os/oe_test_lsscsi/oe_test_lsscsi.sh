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
# @Date      :   2020-07-29
# @License   :   Mulan PSL v2
# @Desc      :   lsscsi test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    DNF_INSTALL lsscsi
}

function run_test() {
    lsscsi 2>/tmp/error.log
    test $(cat /tmp/error.log | wc -l) -eq 0
    CHECK_RESULT $?
}

function post_test() {
    test -f /tmp/error.log && cat /tmp/error.log && rm -f /tmp/error.log
    DNF_REMOVE
}

main $@
