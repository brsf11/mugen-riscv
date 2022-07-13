#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   Test lsyncd.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL lsyncd
    mkdir -p /tmp/htmlcopy
    cat >> /etc/lsyncd.conf << EOF
    sync{default.rsyncssh, source="/var/www/html", host="localhost", targetdir="/tmp/htmlcopy/"}
EOF
    expect <<EOF
    spawn ssh-keygen
    expect "Generating public/private rsa key pair. Enter file in which to save the key"
    send "\n"
    expect "Enter passphrase (empty for no passphrase):"
    send "\n"
    expect "Enter same passphrase again:"
    send "\n"
    expect eof
EOF
    expect <<EOF
        spawn ssh-copy-id -i /root/.ssh/id_rsa.pub ${NODE1_USER}@localhost
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "password" {
                send "${NODE1_PASSWORD}\\r"
            }
        }
        expect eof
EOF
    mkdir -p /var/www/html/
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution lsyncd.service
    test_reload lsyncd.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop lsyncd.service
    DNF_REMOVE
    rm -rf /var/www /var/log/lsyncd /tmp/htmlcopy /etc/lsyncd.conf
    kill -9 $(ps -ef | grep "lsyncd" | grep -Ev "grep|bash" | awk '{print $2}')
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
