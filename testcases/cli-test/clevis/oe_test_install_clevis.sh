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
# @Desc      :   Install clevis
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function config_params() {
    PATH_TANG="/var/db/tang"
}

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "clevis tang firewalld"
    systemctl start firewalld
    ls /etc/systemd/system/tangd.socket.d && rm -rf /etc/systemd/system/tangd.socket.d
    firewall-cmd --add-port=8009/tcp
    firewall-cmd --runtime-to-permanent
    SOCKET_CONTENT='[Socket]\nListenStream=\nListenStream=8009'
    mkdir /etc/systemd/system/tangd.socket.d
    echo -e ${SOCKET_CONTENT} > /etc/systemd/system/tangd.socket.d/override.conf
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    systemctl enable tangd.socket
    CHECK_RESULT $? 0 0 "Failed to systemctl enable tangd.socket"
    systemctl daemon-reload
    systemctl show tangd.socket -p Listen | grep 8009
    CHECK_RESULT $? 0 0 "Failed to display the 'Listen' property of tangd.socket"
    SLEEP_WAIT 1
    systemctl start tangd.socket
    CHECK_RESULT $? 0 0 "Failed to start tangd.socket service"
    cd $PATH_TANG
    for element in $(ls $PATH_TANG)
    do
        mv $PATH_TANG/$element "$PATH_TANG/.$element"
    done
    /usr/libexec/tangd-keygen $PATH_TANG
    CHECK_RESULT $? 0 0 "Failed to generate a new key using the /var/db/Tang d-keygen command on the Tang server"
    cd $OET_PATH
    tang-show-keys 8009
    CHECK_RESULT $? 0 0 "Failed to check whether the Tang server advertises the signature key from the new key pair"
    SLEEP_WAIT 1
    systemctl restart tangd.socket
    CHECK_RESULT $? 0 0 "Failed to restart tangd.socket service"
    SLEEP_WAIT 1
    curl http://127.0.0.1:8009/adv -o adv.jws
    CHECK_RESULT $? 0 0 "Failed to transfer data to adv.jws file"
    SLEEP_WAIT 1
    echo 'hello' | clevis encrypt tang '{"url":"http://127.0.0.1:8009","adv":"adv.jws"}' > secert.jwe
    CHECK_RESULT $? 0 0 "Failed to encrypt file"
    SLEEP_WAIT 1
    clevis decrypt < secert.jwe | grep 'hello'
    CHECK_RESULT $? 0 0 "Failed to decrypt file"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop tangd.socket
    DNF_REMOVE
    rm -rf secert.jwe adv.jws /etc/systemd/system/tangd.socket.d /var/db/tang
    firewall-cmd --remove-port=8009/tcp
    firewall-cmd --runtime-to-permanent
    LOG_INFO "Finish environment cleanup!"
}
main "$@"

