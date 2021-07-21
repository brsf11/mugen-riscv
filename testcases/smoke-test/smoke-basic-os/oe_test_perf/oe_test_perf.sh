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
# @Date      :   2020-11-10
# @License   :   Mulan PSL v2
# @Desc      :   perf test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "perf file"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    perf list >txt 2>/tmp/error.log
    test -s /tmp/error.log && return 1
    timeout -k 15 1 perf record || ls perf.data
    CHECK_RESULT $?
    file perf.data | grep -i data
    CHECK_RESULT $?
    perf report -i perf.data >/tmp/perf.log
    CHECK_RESULT $?
    file /tmp/perf.log | grep -i ASCII
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf perf.data /tmp/perf.log txt /tmp/error.log
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main $@
