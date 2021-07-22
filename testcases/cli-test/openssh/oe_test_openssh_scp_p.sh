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
# @Desc      :   SCP keeps the permission information of the source file
# #############################################
source "${OET_PATH}/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."
    echo "openEuler" >/tmp/file_push
    chmod 777 /tmp/file_push
    expect <<EOF
        spawn scp -p /tmp/file_push ${NODE2_USER}@${NODE2_IPV4}:/tmp
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
    SSH_CMD "
    grep openEuler /tmp/file_push 
    ls -l /tmp/file_push | grep 'rwxrwxrwx'
    " "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    expect <<EOF
        spawn scp -p ${NODE2_USER}@${NODE2_IPV4}:/tmp/file_push /tmp/file_pull
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
    ls -l /tmp/file_pull | grep 'rwxrwxrwx'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /tmp/file_*
    SSH_CMD "rm -rf /tmp/file_*" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    LOG_INFO "End to restore the test environment."
}

main "$@"
