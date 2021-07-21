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
    vhost_name="myvhost"
    DNF_INSTALL rabbitmq-server
    which firewalld && systemctl stop firewalld
    systemctl restart rabbitmq-server
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    rabbitmqctl eval 'rabbit_amqqueue:declare({resource, <<"/">>, queue, <<"test-queue">>}, true, false, [], none, "test").'
    rabbitmqctl add_vhost ${vhost_name}
    rabbitmqctl status | grep "Status of node"
    CHECK_RESULT $?
    rabbitmqctl node_health_check | grep "Health check passed"
    CHECK_RESULT $?
    rabbitmqctl environment | grep "Application environment of node"
    CHECK_RESULT $?
    rabbitmqctl report | grep "Reporting server status of node"
    CHECK_RESULT $?
    rabbitmqctl eval 'node().' | grep "rabbit@"
    CHECK_RESULT $?
    con_pid=$(rabbitmqctl list_queues pid | sed -n '$p')
    rabbitmqctl close_connection "${con_pid}" "go away" | grep "go away"
    CHECK_RESULT $?
    rabbitmqctl close_all_connections --limit 10 'Please close' | grep "Please close"
    CHECK_RESULT $?
    rabbitmqctl trace_on -p ${vhost_name} | grep "Trace enabled for vhost"
    CHECK_RESULT $?
    rabbitmqctl trace_off -p ${vhost_name} | grep "Trace disabled for vhost"
    CHECK_RESULT $?
    rabbitmqctl set_vm_memory_high_watermark 0.5 | grep "Setting memory threshold on"
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop rabbitmq-server
    DNF_REMOVE
    rm -rf /var/lib/rabbitmq/
    kill -9 $(pgrep -u rabbitmq)
    which firewalld && systemctl start firewalld
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
