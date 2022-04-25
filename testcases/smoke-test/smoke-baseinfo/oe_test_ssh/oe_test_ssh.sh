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
# @Date      :   2022/04/19
# @License   :   Mulan PSL v2
# @Desc      :   Test SSH link
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

sshcmd() {
    cmd=${1}
    rmt_ip=${2-127.0.0.1}

    [ -z "${cmd}" ] && {
        echo "[X] CMD is null"
        return 1
    }

    expect <<EOF1
        set timeout 15
        spawn ssh root@${rmt_ip} "${cmd}"
        expect {
                "*(yes/no?" {
                send "yes\r"
                }
        }
        expect {
                "assword:" {
                send "${NODE1_PASSWORD}\r"
                }
        }
        expect eof

        catch wait result;
        exit [lindex \$result 3]
EOF1
    retcode=$?
    echo "retcode of sshcmd is ${retcode}"
    return ${retcode}
}

function run_test() {
    LOG_INFO "Start to run test."
    systemctl restart sshd
    CHECK_RESULT $? 0 0 "Failed to start sshd service"
    systemctl status sshd | grep running
    CHECK_RESULT $? 0 0 "Failed to start sshd service"
    sshcmd "uname -a"
    CHECK_RESULT $? 0 0 "uanme -a execution failed"
    sshcmd "ip a"
    CHECK_RESULT $? 0 0 "ip a execution failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /root/.ssh/known_hosts
    LOG_INFO "End to restore the test environment."
}

main "$@"
