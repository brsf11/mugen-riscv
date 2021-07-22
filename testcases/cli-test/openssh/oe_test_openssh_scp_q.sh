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
# @Desc      :   Silent mode of SCP
# #############################################
source "${OET_PATH}/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF
        log_file /tmp/log_scp_pull
        spawn scp -q ${NODE2_USER}@${NODE2_IPV4}:/etc/openEuler-latest /tmp/openEuler-latest
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "password" {
                send "${NODE2_PASSWORD}\\r" 
            }
        }
        expect eof
EOF
    CHECK_RESULT $?
    grep "openEuler" /tmp/openEuler-latest
    CHECK_RESULT $?
    grep "100%" /tmp/log_scp_pull
    CHECK_RESULT $? 0 1
    expect <<EOF
        log_file /tmp/log_scp_push
        spawn scp -q /etc/openEuler-latest ${NODE2_USER}@${NODE2_IPV4}:/tmp/openEuler-latest
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "password" {
                send "${NODE2_PASSWORD}\\r"
            }
        }
        expect eof
EOF
    CHECK_RESULT $?
    SSH_CMD "grep openEuler /tmp/openEuler-latest" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    grep "100%" /tmp/log_scp_push
    CHECK_RESULT $? 0 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /tmp/openEuler-latest /tmp/log_scp*
    SSH_CMD "rm -rf /tmp/openEuler-latest" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    LOG_INFO "End to restore the test environment."
}

main "$@"
