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
# @Date      :   2020/7/24
# @License   :   Mulan PSL v2
# @Desc      :   Check passwd and shadow files
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start executing testcase."
    ls -l /etc/passwd | grep '\-rw\-r\-\-r\-\-'
    CHECK_RESULT $? 0 0 "check permission of /etc/passwd failed"
    ls -l /etc/shadow | grep '\-\-\-\-\-\-\-\-\-\-'
    CHECK_RESULT $? 0 0 "check permission of /etc/shadow failed"
    useradd example
    passwd example <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    grep ${NODE1_PASSWORD} /etc/shadow
    CHECK_RESULT $? 0 1 "exist password in /etc/shadow"
    grep -r ${NODE1_PASSWORD} /var/log
    CHECK_RESULT $? 0 1 "exist password in /var/log"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -rf example
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
