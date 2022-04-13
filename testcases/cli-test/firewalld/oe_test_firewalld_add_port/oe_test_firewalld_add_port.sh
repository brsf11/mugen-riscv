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
# @Desc      :   Use firewall to control ports
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL httpd
    sudo systemctl start httpd
    sudo systemctl start firewalld
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    if ! sudo firewall-cmd --list-port | grep 80/tcp; then
        ret=1
        sudo firewall-cmd --add-port=80/tcp
        sudo firewall-cmd --runtime-to-permanent
        sudo firewall-cmd --list-ports | grep 80/tcp
        CHECK_RESULT $?
    fi
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0
    sudo firewall-cmd --remove-port=80/tcp
    sudo firewall-cmd --runtime-to-permanent
    sudo firewall-cmd --list-ports | grep 80/tcp
    CHECK_RESULT $? 0 1
    SSH_CMD "curl http://$NODE1_IPV4" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1
    test -z $ret && {
        sudo firewall-cmd --add-port=80/tcp
        sudo firewall-cmd --runtime-to-permanent
    }
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo systemctl stop httpd
    sudo firewall-cmd --reload
    sudo systemctl start firewalld
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
