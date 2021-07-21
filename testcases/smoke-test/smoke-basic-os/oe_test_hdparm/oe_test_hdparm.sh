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
# @Desc      :   hdparm test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    DNF_INSTALL "hdparm util-linux"
}

function run_test() {
    disk=$(lsblk -S -o NAME,TYPE | grep -v NAME | head -1 | awk '{print $1}')
    if [ -z "${disk}" ]; then
        LOG_INFO "no available disk found, skip $0"
        return 1
    fi

    hdparm -a /dev/"${disk}" | grep readahead
    CHECK_RESULT $?
    hdparm -r /dev/"${disk}" | grep readonly
    CHECK_RESULT $?
    hdparm -F /dev/"${disk}"
    CHECK_RESULT $?
}

function post_test() {
    DNF_REMOVE
}
main $@
