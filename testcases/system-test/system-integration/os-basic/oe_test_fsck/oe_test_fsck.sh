#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.


source "$OET_PATH/libs/locallibs/common_lib.sh"
function config_params() {
    LOG_INFO "Start loading data!"
    TEST_DISK="/dev/$(TEST_DISK 1)"
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environmental preparation."
    echo -e "n\np\n\n\n\nw"| fdisk "${TEST_DISK}"
    mkfs.ext4 "${TEST_DISK}1"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    fsck -t msdos -a "${TEST_DISK}1" | grep fsck
    CHECK_RESULT $?
    fsck.minix "${TEST_DISK}1" 2>&1 | grep fsck.minix
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    mkfs.ext4 ${TEST_DISK}1 -F
    echo -e "d\n\nw"| fdisk "${TEST_DISK}"
    LOG_INFO "Finish environment cleanup!"
}
main "$@"