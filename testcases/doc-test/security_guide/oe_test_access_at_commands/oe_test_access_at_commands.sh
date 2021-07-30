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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @modify    :   yang_lijin@qq.com
# @Date      :   2021/05/11
# @License   :   Mulan PSL v2
# @Desc      :   Verify restrict access to at commands
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "at"
    grep "^testuser1:" /etc/passwd && userdel -rf testuser1
    grep "^testuser2:" /etc/passwd && userdel -rf testuser2
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    useradd testuser1
    grep "^testuser1:" /etc/passwd
    CHECK_RESULT $? 0 0 "add testuser1 failed"
    useradd testuser2
    grep "^testuser2:" /etc/passwd
    CHECK_RESULT $? 0 0 "add testuser2 failed"
    echo testuser1 >>/etc/at.allow
    grep "^testuser1" /etc/at.allow
    su - testuser1 -c "id 2>&1" | grep "testuser1"
    CHECK_RESULT $? 0 0 "su testuser1 failed"
    su - testuser1 -c "at 2>&1" | grep "Garbled time"
    CHECK_RESULT $? 0 0 "testuser1 exec at failed"
    su - testuser2 -c "id 2>&1" | grep "testuser2"
    CHECK_RESULT $? 0 0 "su testuser2 failed"
    su - testuser2 -c "at 2>&1" | grep "You do not have permission to use at"
    CHECK_RESULT $? 0 0 "testuser2 exec at failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    mv /etc/at.allow-bak /etc/at.allow -f
    userdel -rf testuser1
    userdel -rf testuser2
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
