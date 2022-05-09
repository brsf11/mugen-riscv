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
# @Desc      :   check file right part 1
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."

    find /dev/mem -type f -user root -group root -perm 640
    CHECK_RESULT $? 0 0 "check /dev/mem file right fail"

    find /etc/fstab -type f -user root -group root -perm 600
    CHECK_RESULT $? 0 0 "check /etc/fstab file right fail"

    find /etc/group -type f -user root -group root -perm 644
    CHECK_RESULT $? 0 0 "check /etc/group file right fail"

    find /etc/init.d/ -type f -user root -group root -perm 750
    CHECK_RESULT $? 0 0 "check /etc/init.d/ file right fail"

    getFileNum=$("find /etc/init.d/* -type f -user root -group root -perm 750 | wc -l")
    allFileNum=$("find /etc/init.d/* -type f | wc -l")
    test "$getFileNum" -eq "$allFileNum"
    CHECK_RESULT $? 0 1 "check /etc/init.d/* file right fail"

    find /etc/passwd -type f -user root -group root -perm 644
    CHECK_RESULT $? 0 0 "check /etc/passwd file right fail"

    find /etc/securetty -type f -user root -group root -perm 600
    CHECK_RESULT $? 0 0 "check /etc/securetty file right fail"

    find /etc/security/opasswd -type f -user root -group root -perm 600
    CHECK_RESULT $? 0 0 "check /etc/security/opasswd file right fail"

    find /etc/shadow -type f -user root -group root -perm 600
    CHECK_RESULT $? 0 0 "check /etc/shadow file right fail"

    getFileNum=$("find /etc/ssh/*key -type f -user root -group root -perm 400 | wc -l")
    allFileNum=$("find /etc/ssh/*key -type f | wc -l")
    test "$getFileNum" -eq "$allFileNum"
    CHECK_RESULT $? 0 1 "check /etc/ssh/*key file right fail"

    getFileNum=$("find find /etc/ssh/*key.pub -type f -user root -group root -perm 644 | wc -l")
    allFileNum=$("find /etc/ssh/*key.pub -type f | wc -l")
    test "$getFileNum" -eq "$allFileNum"
    CHECK_RESULT $? 0 1 "check /etc/ssh/*key.pub file right fail"

    LOG_INFO "Finish testcase execution."
}

main "$@"