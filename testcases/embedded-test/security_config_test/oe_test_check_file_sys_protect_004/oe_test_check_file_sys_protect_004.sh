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
# @Desc      :   check file right part 3
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."

    find /bin/ -type d -user root -group root -perm 755
    CHECK_RESULT $? 0 0 "check /bin/ file right fail"

    find /etc/ -type d -user root -group root -perm 755
    CHECK_RESULT $? 0 0 "check /etc/ file right fail"

    find /home/ -type d -user root -group root -perm 755
    CHECK_RESULT $? 0 0 "check /home/ file right fail"

    find /lib/ -type d -user root -group root -perm 755
    CHECK_RESULT $? 0 0 "check /lib/ file right fail"

    find /dev/ -type d -user root -group root -perm 755
    CHECK_RESULT $? 0 0 "check /dev/ file right fail"

    find /init -type l -user root -group root -perm 777
    CHECK_RESULT $? 0 0 "check /init file right fail"
    
    find /sbin/init -type f -user root -group root -perm 755
    CHECK_RESULT $? 0 0 "check /sbin/init file right fail"

    find /var/volatile/log -type f -user root -group root -perm 750
    CHECK_RESULT $? 0 0 "check /var/volatile/log file right fail"

    find /etc/motd -type f -user root -group root -perm 644
    CHECK_RESULT $? 0 0 "check /etc/motd file right fail"

    find /etc/issue -type f -user root -group root -perm 644
    CHECK_RESULT $? 0 0 "check /etc/issue file right fail"

    find /etc/issue.net -type f -user root -group root -perm 644
    CHECK_RESULT $? 0 0 "check /etc/issue.net file right fail"

    LOG_INFO "Finish testcase execution."
}

main "$@"