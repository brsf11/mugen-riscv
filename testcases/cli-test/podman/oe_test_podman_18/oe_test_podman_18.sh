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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2021/01/11
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in podman package
# ############################################

source "../common/common_podman.sh"
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    podman pull postgres:alpine
    podman run --name postgres -e POSTGRES_PASSWORD=secret -d postgres:alpine
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    podman port --all | grep "$(podman ps -aq)"
    CHECK_RESULT $?
    podman port --latest
    CHECK_RESULT $?
    expect <<EOF
        set time 30
        spawn podman login docker.io 
        expect {
            "Username*" { send "umohnani\r"; exp_continue }
            "Password:" { send "\r" }
        }
        expect eof
EOF
    CHECK_RESULT $?
    podman logout docker.io
    CHECK_RESULT $?
    expect <<EOF
        set time 30
        spawn podman login --authfile authdir/myauths.json docker.io
        expect {
            "Username*" { send "umohnani\r"; exp_continue }
            "Password:" { send "\r" }
        }
        expect eof
EOF
    CHECK_RESULT $?
    podman logout --authfile authdir/myauths.json docker.io
    CHECK_RESULT $?
    expect <<EOF
        set time 30
        spawn podman login -u umohnani docker.io
        expect {
            "Password:" { send "\r" }
        }
        expect eof
EOF
    CHECK_RESULT $?
    expect <<EOF
        set time 30
        spawn podman login --tls-verify=false docker.io
        expect {
            "Username*" { send "umohnani\r"; exp_continue }
            "Password:" { send "\r" }
        }
        expect eof
EOF
    CHECK_RESULT $?
    podman logout --all | grep "Remove"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    rm -rf $(ls | grep -vE ".sh")
    LOG_INFO "End to restore the test environment."
}

main "$@"
