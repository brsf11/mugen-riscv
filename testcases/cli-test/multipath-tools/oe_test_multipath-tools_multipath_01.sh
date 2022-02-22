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
    multipath -v3 | grep ${local_disk}
    CHECK_RESULT $?
    multipath -ll | grep "mpath" -A 10
    CHECK_RESULT $?
    multipath -l | grep "mpath" -A 10
    CHECK_RESULT $?
    multipath -v3 -f /dev/$test_dm
    CHECK_RESULT $?
    test -L /dev/mapper/${test_mapper}1
    CHECK_RESULT $? 1
    service multipathd restart
    sleep 10
    multipath -v3 -R 1 -F
    CHECK_RESULT $?
    test -L /dev/mapper/${test_mapper}
    CHECK_RESULT $? 1
    service multipathd restart
    multipath -a /dev/$test_dm | grep "added"
    CHECK_RESULT $?
    grep "0000" /etc/multipath/wwids
    CHECK_RESULT $?
    multipath -v3 -C /dev/$test_dm 2>&1 | grep -E "checker|sda|/dev/$test_dm"
    CHECK_RESULT $?
    multipath -v3 -q 2>&1 | grep -C 10 "paths list"
    CHECK_RESULT $?
    multipath -v3 -d 2>&1 | grep -i "dev"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "End to restore the test environment."
}

main "$@"
