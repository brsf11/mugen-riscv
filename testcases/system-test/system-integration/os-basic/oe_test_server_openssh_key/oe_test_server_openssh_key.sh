#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-4-9
# @License   :   Mulan PSL v2
# @Desc      :   Generating SSH key pairs
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "openssh-server openssh-clients openssh"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    expect -c "
        set timeout 30
        log_file testlog1
        spawn ssh-keygen -t ecdsa
        expect {
        \"Enter*\" {send \"\n\r\"
        expect \"Enter*\" {send \"\n\r\"}
        expect \"Enter*\" {send \"\n\r\"}
        }
    }
    expect eof
    "
    grep -i 'error|fail|while executing' testlog1
    CHECK_RESULT $? 1

    expect -c "
        set timeout 30
        log_file testlog2
        spawn ssh-copy-id root@$NODE2_IPV4
        expect {
            \"*password*\" {send \"$NODE2_PASSWORD\r\"
        }
    }
    expect eof
    "
    grep -i 'error|fail|while executing' testlog2
    CHECK_RESULT $? 1

    expect -c "
        set timeout 30
        log_file testlog3
        spawn ssh root@$NODE2_IPV4
        expect {
            \"root*\" {send \"exit\r\"
        }
    }
    expect eof
    "
    grep -i 'error|fail|while executing' testlog3
    CHECK_RESULT $? 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restores the test environment."
    SSH_CMD "rm -rf /root/.ssh/authorized_keys" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    rm -rf testlog[1-3]
    LOG_INFO "End to restore the test environment."
}

main $@
