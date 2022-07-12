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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @modify    :   wangxiaoya@qq.com
# @Date      :   2022/05/06
# @License   :   Mulan PSL v2
# @Desc      :   Ignore all DAC access restrictions on files
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    grep "^example:" /etc/passwd && userdel -rf example
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    useradd example
    passwd example <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    su - example -c 'less /etc/shadow' 2>&1 | grep "Permission denied"
    CHECK_RESULT $? 0 0 "Failed to switch example user to view '/etc/shadow' document and obtain 'Permission denied' field"
    setcap cap_dac_override=eip /usr/bin/less
    CHECK_RESULT $? 0 0 "Failed to set cap"
    getcap /usr/bin/less | grep "/usr/bin/less" | grep cap_dac_override.eip
    CHECK_RESULT $? 0 0 "Failed to get cap"
    su - example -c 'less /etc/shadow | grep root'
    CHECK_RESULT $? 0 0 "Failed to switch example user to view '/etc/shadow' document and obtain 'root' field"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    setcap -r /usr/bin/less
    userdel -rf example
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
