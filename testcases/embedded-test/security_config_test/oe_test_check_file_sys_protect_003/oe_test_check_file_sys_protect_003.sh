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
# @Author    :   saarloos
# @Contact   :   9090-90-90-9090@163.com
# @Modify    :   9090-90-90-9090@163.com
# @Date      :   2022/04/25
# @License   :   Mulan PSL v2
# @Desc      :   check file right part 2
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."
    
    find /etc/ssh/sshd_config -type f -user root -group root -perm 600
    CHECK_RESULT $? 0 0 "check /etc/ssh/sshd_config file right fail"

    find /etc/sysctl.conf -type f -user root -group root -perm 600
    CHECK_RESULT $? 0 0 "check /etc/sysctl.conf file right fail"

    find /lib/ -name modules -type d -user root -group root -perm 750
    CHECK_RESULT $? 0 0 "check /lib/modules/ file right fail"

    find /root/ -type f -user root -group root -perm 700
    CHECK_RESULT $? 0 0 "check /root/ file right fail"

    find /tmp/ -type f -user root -group root -perm 1777
    CHECK_RESULT $? 0 0 "check /tmp/ file right fail"

    find /dev/shm -type f -user root -group root -perm 1777
    CHECK_RESULT $? 0 0 "check /dev/shm file right fail"

    find /var/log/ -name audit -type d -user root -group root -perm 750
    CHECK_RESULT $? 0 0 "check /var/log/audit/ file right fail"

    find /var/log/audit/audit.log -type f -user root -group root -perm 600
    CHECK_RESULT $? 0 0 "check /var/log/audit/audit.log file right fail"

    find /var/ -name log -type d -user root -group root -perm 750
    CHECK_RESULT $? 0 0 "check /var/log/ file right fail"

    getFileNum=$("find /var/log/* -type f -user root -group root -perm 640 | wc -l")
    allFileNum=$("find /var/log/* -type f | wc -l")
    test "$getFileNum" -eq "$allFileNum"
    CHECK_RESULT $? 0 1 "check /var/log/* file right fail"

    if [ -e /var/log/secure ]; then
        find /var/log/secure -type f -user root -group root -perm 640
        CHECK_RESULT $? 0 0 "check /var/log/secure file right fail"
    else
        find /var/log/auth.log -type f -user root -group root -perm 640
        CHECK_RESULT $? 0 0 "check /var/log/secure file right fail"
    fi

    find /var/log/wtmp -type f -user root -group root -perm 640
    CHECK_RESULT $? 0 0 "check /var/log/wtmp file right fail"

    LOG_INFO "Finish testcase execution."
}

main "$@"