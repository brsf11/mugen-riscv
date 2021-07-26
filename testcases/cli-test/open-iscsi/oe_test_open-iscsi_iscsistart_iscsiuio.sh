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
#@Date      	:   2020-11-28
#@License   	:   Mulan PSL v2
#@Desc      	:   command test-iscsid
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
    iscsistart -h | grep "Usage"
    CHECK_RESULT $?
    test "$(iscsistart -v | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*")" == \
        "$(rpm -qi open-iscsi | grep "Version" | awk '{print$3}')"
    CHECK_RESULT $?
    iscsiuio -h | grep "Usage"
    CHECK_RESULT $?
    iscsiuio -v | grep -oE "Version.*[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"
    CHECK_RESULT $?
    iscsiuio -f -d 4 >./iscsiuio_log.result 2>&1 &
    systemctl restart iscsid
    SLEEP_WAIT 2
    iscsiadm -m node -T iqn.2020-08.com.example:server -p "${NODE2_IPV4}" -u
    iscsistart -i iqn.2020-08.com.example:client -t "iqn.2020-08.com.example:server" -g 1 -a "${NODE2_IPV4}" -p 3260 2>&1 | grep 'operational now'
    CHECK_RESULT $?
    systemctl restart iscsid
    SLEEP_WAIT 2
    iscsiadm -m node -T iqn.2020-08.com.example:server -p "${NODE2_IPV4}" -u | grep 'successful'
    CHECK_RESULT $?
    iscsistart -i iqn.2020-08.com.example:client -t "iqn.2020-08.com.example:server" -g 1 -a "${NODE2_IPV4}" -p 3260 -u admin -w 123456 -d 4 2>&1 | grep 'operational now'
    CHECK_RESULT $?
    systemctl restart iscsid
    SLEEP_WAIT 2
    iscsiadm -m node -T iqn.2020-08.com.example:server -p "${NODE2_IPV4}" -u | grep 'successful'
    CHECK_RESULT $?
    iscsistart -i iqn.2020-08.com.example:client -t "iqn.2020-08.com.example:server" -g 1 -a "${NODE2_IPV4}" -p 3260 -U admin -W 123456 2>&1 | grep 'operational now'
    CHECK_RESULT $?
    systemctl restart iscsid
    SLEEP_WAIT 2
    iscsiadm -m node -T iqn.2020-08.com.example:server -p "${NODE2_IPV4}" -u | grep 'successful'
    CHECK_RESULT $?
    iscsistart -i iqn.2020-08.com.example:client -t "iqn.2020-08.com.example:server" -g 1 -a "${NODE2_IPV4}" -p 3260 -u admin -w 123456 -P node.session.auth.authmethod=CHAP 2>&1 | grep 'operational now'
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
    pkill -9 iscsiuio_log
    rm -rf ./*.result
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
