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
# @Desc      :   Upload and download based on SFTP
# #############################################
source "${OET_PATH}/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    echo "localhost" >/tmp/hostname
    SSH_CMD "
    echo 'localhost' >/tmp/hostname
    useradd sftpuser -d /home/sftpuser -p ${NODE2_PASSWORD}
    chown -R root /home/sftpuser/
    systemctl restart sshd
    " "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    expect <<EOF
    spawn sftp root@${NODE2_IPV4}
    expect {
        "*yes/no*" {
                send "yes\\r"
        }
    }
    expect {
        "*password:" {
            send "${NODE2_PASSWORD}\\r"
        }
    }
    expect {
        "sftp>" {
            send "ls\\r"
        }
    }
    expect {
        "sftp>" {
            send "get /tmp/hostname /home/\\r"
        }
    }
    expect {
        "sftp>" {
            send "put /tmp/hostname /home/sftpuser/\\r"
        }
    }
    expect {
        "sftp>" {
            send "exit\\r"
        }
    }
    expect eof
EOF
    CHECK_RESULT $?
    SSH_CMD "
    grep localhost /home/sftpuser/hostname
    " "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    grep localhost /home/hostname
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    SSH_CMD "
    chown -R sftpuser /home/sftpuser/
    userdel -r sftpuser
    rm -rf /home/sftpuser/hostname /tmp/hostname
    systemctl restart sshd
    " "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    rm -rf /home/hostname /tmp/hostname
    LOG_INFO "End to restore the test environment."
}

main "$@"
