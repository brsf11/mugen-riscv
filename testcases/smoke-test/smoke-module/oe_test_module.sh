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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/04/25
# @License   :   Mulan PSL v2
# @Desc      :   Test SSH link
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    module_list=$(lsmod | grep -w 0 | awk '{print $1}' | grep -vE "Module|virtio|net_failover")
    module_used_list=$(lsmod | grep -vw 0 | awk '{print $1}' | grep -vE "Module|virtio|net_failover")
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    for mod in ${module_list}; do
        modprobe -r ${mod}
        CHECK_RESULT $? 0 0 "Failed to delete ${mod}"
        lsmod | grep -w ${mod}
        CHECK_RESULT $? 1 0 "Failed to delete ${mod}"
        modprobe ${mod}
        CHECK_RESULT $? 0 0 "Failed to load ${mod}"
        lsmod | grep -w ${mod}
        CHECK_RESULT $? 0 0 "Failed to load ${mod}"
    done

    for mod in ${module_used_list}; do
        modprobe ${mod}
        CHECK_RESULT $? 0 0 "Failed to load ${mod}"
        lsmod | grep -w ${mod}
        CHECK_RESULT $? 0 0 "Failed to load ${mod}"
    done
    LOG_INFO "End to run test."
}

main "$@"
