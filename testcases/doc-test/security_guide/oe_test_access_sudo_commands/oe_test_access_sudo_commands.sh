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
# @MOdify    :   yang_lijin@qq.com
# @Date      :   2021/7/23
# @License   :   Mulan PSL v2
# @Desc      :   Verify restrictions on sudo commands
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    grep "^testuser:" /etc/passwd && userdel -rf testuser
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    grep "^%wheel" /etc/sudoers
    CHECK_RESULT $? 0 0 "grep %wheel failed"
    useradd testuser
    CHECK_RESULT $? 0 0 "add testuser failed"
    passwd testuser <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    usermod -g wheel testuser
    groups testuser | grep "testuser : wheel"
    CHECK_RESULT $? 0 0 "usermod -g wheel testuser failed"
    su testuser -c "echo ${NODE1_PASSWORD} | sudo -S ls /etc" 2>&1 | grep 'testuser is not in the sudoers file.  This incident will be reported.'
    CHECK_RESULT $? 0 1 "use sudo failed"
    sed -i '/wheel/s/^/#&/g' /etc/sudoers
    grep "^#%wheel" /etc/sudoers
    CHECK_RESULT $? 0 0 "grep #%wheel failed"
    su testuser -c "echo ${NODE1_PASSWORD} | sudo -S ls /etc" 2>&1 | grep 'testuser is not in the sudoers file.  This incident will be reported.' 
    CHECK_RESULT $? 0 0 "use sudo failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    sed -i 's/#%wheel/%wheel/g' /etc/sudoers
    userdel -rf testuser
    groupdel testuser
    rm -rf /run/faillock/testuser 
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
