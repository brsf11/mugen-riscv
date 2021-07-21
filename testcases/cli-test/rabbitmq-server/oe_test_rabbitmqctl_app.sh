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
# @Desc      :   Testing rabbitmq-server command parameters
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL rabbitmq-server
    which firewalld && systemctl stop firewalld
    systemctl restart rabbitmq-server
    platform=$(uname -i)
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    rabbitmqctl stop | grep "Stopping and halting"
    CHECK_RESULT $?
    systemctl restart rabbitmq-server
    rabbitmqctl shutdown | grep "Shutting down RabbitMQ node"
    CHECK_RESULT $?
    systemctl restart rabbitmq-server
    rabbitmqctl stop_app | grep "Stopping rabbit application "
    CHECK_RESULT $?
    rabbitmqctl start_app | grep "Starting node"
    CHECK_RESULT $?
    pid_file=$(find /var/lib/rabbitmq/mnesia/ -name "*.pid")
    rabbitmqctl wait "${pid_file}" | grep "Waiting for"
    CHECK_RESULT $?
    rabbitmqctl stop_app
    rabbitmqctl reset | grep "Resetting node"
    CHECK_RESULT $?
    rabbitmqctl force_reset | grep "Forcefully resetting node"
    CHECK_RESULT $?
    rabbitmqctl start_app
    rabbitmqctl rotate_logs | grep "Rotating logs"
    CHECK_RESULT $?
    if [ "$platform" = x86_64 ]; then
        rabbitmqctl hipe_compile /tmp/rabbit-hipe/ebin | grep "Compiled"
        CHECK_RESULT $?
        test -d /tmp/rabbit-hipe/ebin
        CHECK_RESULT $?
    fi
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop rabbitmq-server
    DNF_REMOVE
    rm -rf /var/lib/rabbitmq/
    which firewalld && systemctl start firewalld
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
