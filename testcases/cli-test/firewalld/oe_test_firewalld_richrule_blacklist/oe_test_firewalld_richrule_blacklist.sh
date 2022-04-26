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
# @Date      :   2022/04/22
# @License   :   Mulan PSL v2
# @Desc      :   Add the source address to the blacklist and disallow all connections from this source address
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    sudo systemctl start firewalld
    source_ip=$(echo "${NODE1_IPV4%\.*\.*}.0.0")
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    sudo firewall-cmd --zone=public --add-rich-rule 'rule family=ipv4 source address='$source_ip'/16 accept'
    CHECK_RESULT $?
    nc -l -p 5555 >/tmp/tmp_log 2>&1 &
    SSH_CMD "echo test | nc ${NODE1_IPV4} 5555" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 0

    grep 'test' /tmp/tmp_log
    CHECK_RESULT $?

    sudo firewall-cmd --zone=public --remove-rich-rule 'rule family=ipv4 source address='$source_ip'/16 accept'
    CHECK_RESULT $?
    nc -l -p 5555 >/tmp/tmp_log 2>&1 &
    SSH_CMD "echo test | nc ${NODE1_IPV4} 5555" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1

    sudo firewall-cmd --zone=public --add-rich-rule 'rule family=ipv4 source address='$source_ip'/16 accept'
    CHECK_RESULT $?
    nc -l -p 5555 >/tmp/tmp_log 2>&1 &
    SSH_CMD "echo test | nc ${NODE1_IPV4} 5555" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 0

    grep 'test' /tmp/tmp_log
    CHECK_RESULT $?

    sudo firewall-cmd --zone=public --add-rich-rule 'rule family=ipv4 source address='$source_ip'/16 drop'
    CHECK_RESULT $?
    nc -l -p 5555 >/tmp/tmp_log 2>&1 &
    SSH_CMD "echo test | nc ${NODE1_IPV4} 5555" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1

    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo firewall-cmd --zone=public --remove-rich-rule 'rule family=ipv4 source address='$source_ip'/16 accept'
    sudo firewall-cmd --zone=public --remove-rich-rule 'rule family=ipv4 source address='$source_ip'/16 drop'
    sudo firewall-cmd --reload
    sudo systemctl start firewalld
    rm -rf /tmp/tmp_log
    kill -9 $(pgrep -f 'nc -l -p 5555')
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
