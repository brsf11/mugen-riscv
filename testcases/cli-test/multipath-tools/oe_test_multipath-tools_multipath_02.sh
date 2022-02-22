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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/10/19
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in multipath-tools package
# ############################################

source "common_multipath-tools.sh"
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    local_disks=$(TEST_DISK 1)
    local_disk=$(echo $local_disks | awk -F " " '/sd[a-z]/ {for(i=1;i<=NF;i++) if ($i~/sd/ && $i!~/[0-9]/)j=i;print $j}')
    test_mapper=$(ls /dev/mapper | grep mpath | head -n 1)
    test_dm=$(ls -l /dev/mapper/ | grep ${test_mapper} | awk -F "/" '{print $2}' | head -n 1)
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    multipath -t | grep -E "devices|blacklist_exceptions|blacklist|defaults|overrides"
    CHECK_RESULT $?
    multipath -r -v3 2>&1 | grep "delegating"
    CHECK_RESULT $?
    multipath -i -v3 /dev/mapper/${test_mapper} 2>&1 | grep "scope limited to 3600"
    CHECK_RESULT $?
    cd /etc/multipath/ || exit 1
    multipath -B bindings -v3 2>&1 | grep "binding"
    CHECK_RESULT $?
    multipath -b bindings -v3 /dev/mapper/${test_mapper} 2>&1 | grep "setting: multipath"
    CHECK_RESULT $?
    cd - || exit 1
    multipath -v3 -p multibus 2>&1 | grep "multipath"
    CHECK_RESULT $?
    multipath -c /dev/${local_disk} | grep "MULTIPATH"
    CHECK_RESULT $?
    multipath -W /dev/$test_dm | grep "successfully reset wwids"
    CHECK_RESULT $?
    multipath -w /dev/$test_dm | grep "removed"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
