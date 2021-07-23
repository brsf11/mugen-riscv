#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/29
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of modinfo command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."
    modinfo --help | grep -E "modinfo|-"
    CHECK_RESULT $?
    modinfo -V | grep "kmod version"
    CHECK_RESULT $?
    lsmod | grep "[a-zA-Z0-9]"
    CHECK_RESULT $?
    modinfo -a dm_log | grep "dm-devel@redhat.com"
    CHECK_RESULT $?
    modinfo -d dm_log | grep "device-mapper"
    CHECK_RESULT $?
    modinfo -l dm_log | grep "GPL"
    CHECK_RESULT $?
    modinfo -p raid1 | grep -E "max_queued_requests|int"
    CHECK_RESULT $?
    modinfo -n dm_log | grep "dm-log"
    CHECK_RESULT $?
    modinfo -0 dm_log | grep -aE "filename|dm-log|dm-devel@redhat.com|:"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

main $@
