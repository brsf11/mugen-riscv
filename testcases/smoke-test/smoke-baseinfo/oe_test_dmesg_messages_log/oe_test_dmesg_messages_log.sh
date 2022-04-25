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
# @Date      :   2022/04/19
# @License   :   Mulan PSL v2
# @Desc      :   Test dmesg and messages
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function run_test() {
    LOG_INFO "Start to run test."
    dmesg | grep -iE 'error|fail|not support|no such' | grep -vE "Failed to initialise from firmware|platform does not support|virgl 3d acceleration not supported| _OSC failed| fail to add MMCONFIG information|res=success|CPU model not supported|not support BPF/cgroup firewalling"
    CHECK_RESULT $? 1 0 "Dmesg has false information."
    grep -iE 'error|fail|not support|no such' /var/log/messages | grep -vE "Failed to initialise|platform does not support|Couldn't write 'fq_codel'|Failed to init entropy source|KD_FONT_OP_GET failed while|virgl 3d acceleration|ignorelockingfailure|not support BPF/cgroup firewalling| /etc/lvm/backup/openeuler: stat failed:|Failed to read VG openeuler |ovsdb: Could not connect:|secret-key: failure to generate|dbus-org.freedesktop.resolve1.service|imjournal: No statefile exists|net.ipv4.icmp_ignore_bogus_error_responses|pam_faillock|rasdaemon: wait_access() failed|wait_access\(\) failed|rasdaemon: Can't get|lm_sensors.service|Failed to start Hardware Monitoring Sensors|unit=lm_sensors|/etc/lvm/backup/openeuler_openeuler|package at does not exist| _OSC failed| fail to add MMCONFIG information|failed to open file /etc/ndctl/keys/nvdimm-master|/etc/samba/secrets.tdb\) No such file or directory|Unable to watch \(/root/.ssh/*|ipv6: duplicate address check failed for|linklocal6: failed to generate an address|res=success|Can't open PID file /run/restorecond.pid|CPU model not supported|\[hwrng \]: Initialization Failed|\[rndr  \]: Initialization Failed"
    CHECK_RESULT $? 1 0 "Dmesg has false information."
}

main "$@"
