#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   doraemon2020
#@Contact   	:   xcl_job@163.com
#@Date      	:   2020-12-5
#@License   	:   Mulan PSL v2
#@Desc      	:   command test-iscsiadm
#####################################
source ./common/open-iscsi_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "open-iscsi net-tools"
    DNF_INSTALL "targetcli net-tools" 2
    TARGET_CONF
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    iscsiadm -h | grep "iscsiadm"
    CHECK_RESULT $?
    test "$(iscsiadm -V | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*")" == "$(rpm -qa open-iscsi | awk -F "-" '{print$3}')"
    CHECK_RESULT $?
    iscsiadm -m discoverydb -t st -p "${NODE2_IPV4}" -I iface."${LOCAL_NICS}" --discover | grep 'iqn.2020-08.com.example:server'
    CHECK_RESULT $?
    iscsiadm -m discovery -t st -p "${NODE2_IPV4}" -I iface."${LOCAL_NICS}" --discover | grep 'iqn.2020-08.com.example:server'
    CHECK_RESULT $?
    iscsiadm -m discoverydb -d 4 -P 1 -t sendtargets -p "${NODE2_IPV4}" --discover | grep 'iqn.2020-08.com.example:server'
    CHECK_RESULT $?
    iscsiadm -m discovery -d 4 -P 1 -t sendtargets -p "${NODE2_IPV4}" --discover | grep 'iqn.2020-08.com.example:server'
    CHECK_RESULT $?
    iscsiadm -m discoverydb -t st -p "${NODE2_IPV4}" -o show | grep 'sendtargets'
    CHECK_RESULT $?
    iscsiadm -m discoverydb -t st -p "${NODE2_IPV4}" -n iqn.2020-08.com.example:server | grep 'sendtargets'
    CHECK_RESULT $?
    iscsiadm -m node -d 4 -P 1 −T iqn.2020-08.com.example:server -p "${NODE2_IPV4}":3260 --login 2>&1 | grep -E 'successful|already present'
    CHECK_RESULT $?
    iscsiadm -m node −T iqn.2020-08.com.example:server -p "${NODE2_IPV4}":3260 | grep 'iqn.2020-08.com.example:client'
    CHECK_RESULT $?
    SLEEP_WAIT 2
    iscsiadm -m node -d 4 -P 1 −T iqn.2020-08.com.example:server -p "${NODE2_IPV4}":3260 --logout 2>&1 | grep 'successful'
    CHECK_RESULT $?
    iscsiadm -m node -L all -U all -d 0 -P 1 -o show | grep 'successful'
    CHECK_RESULT $?
    iscsiadm -m node -d 4 -P 1 −T iqn.2020-08.com.example:server -p "${NODE2_IPV4}":3260 --logout 2>&1 | grep 'successful'
    CHECK_RESULT $?
    iscsiadm -m node −T iqn.2020-08.com.example:server -p "${NODE2_IPV4}":3260 --login 2>&1 | grep 'successful'
    CHECK_RESULT $?
    sid="$(iscsiadm -m session -P 3 | grep 'SID' | awk -F " " '{print$2}')"
    CHECK_RESULT "${sid}" 0 1
    iscsiadm -m session -r "${sid}" | grep 'iqn.2020-08.com.example:server'
    CHECK_RESULT $?
    iscsiadm -m session -n iqn.2020-08.com.example:server -o show | grep "${NODE2_IPV4}"
    CHECK_RESULT $?
    iscsiadm -m session -r "${sid}" -u | grep 'successful'
    CHECK_RESULT $?
    iscsiadm -m iface -I iface0 --op=new | grep 'New interface iface0 added'
    CHECK_RESULT $?
    iscsiadm -m iface -I iface0 --op=update -n iface.hwaddress -v 52:54:00:5f:2c:52
    CHECK_RESULT $?
    grep "52:54:00:5f:2c:52" /etc/iscsi/ifaces/iface0
    CHECK_RESULT $?
    iscsiadm -m iface -I iface0 --op=update -n iface.ipaddress -v 192.168.1.2
    CHECK_RESULT $?
    grep "192.168.1.2" /etc/iscsi/ifaces/iface0
    CHECK_RESULT $?
    iscsiadm -m node −T iqn.2020-08.com.example:server -p "${NODE2_IPV4}":3260 --login 2>&1 | grep 'successful'
    CHECK_RESULT $?
    iscsiadm -k 0
    CHECK_RESULT $?
    SLEEP_WAIT 2
    iscsiadm -m node −T iqn.2020-08.com.example:server -p "${NODE2_IPV4}":3260 --logout 2>&1 | grep 'iscsid is not running'
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    SSH_CMD "
    dd if=/dev/zero of=/dev/${unused_disk} bs=2G count=1;
    rm -rf /tmp/disk_info.sh;
    " "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    DNF_REMOVE
    rm -rf /etc/iscsi/*
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
