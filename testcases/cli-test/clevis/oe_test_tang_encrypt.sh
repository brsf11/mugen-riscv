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
# @Date      :   2020/04/22
# @License   :   Mulan PSL v2
# @Desc      :   Rotate the Tang server key and update the binding
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL tang
    ls /etc/systemd/system/tangd.socket.d && rm -rf /etc/systemd/system/tangd.socket.d
    SOCKET_CONTENT='[Socket]\nListenStream=\nListenStream=8009'
    mkdir /etc/systemd/system/tangd.socket.d
    echo -e ${SOCKET_CONTENT} > /etc/systemd/system/tangd.socket.d/override.conf
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    systemctl daemon-reload
    systemctl start tangd.socket
    CHECK_RESULT $? 0 0 "Failed to start tangd.socket service"
    SLEEP_WAIT 1
    tang-show-keys 8009
    CHECK_RESULT $? 0 0 "Failed to check whether the Tang server advertises the signature key from the new key pair"
    rm -rf /var/db/tang/*
    SLEEP_WAIT 5
    systemctl restart tangd.socket
    CHECK_RESULT $? 0 0 "Failed to restart tangd.socket service"
    SLEEP_WAIT 10
    tang-show-keys 8009
    CHECK_RESULT $? 0 0 "Failed to check whether the Tang server advertises the signature key from the new key pair"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf /etc/systemd/system/tangd.socket.d /var/db/tang
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
