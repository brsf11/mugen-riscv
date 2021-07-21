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
    rabbitmqctl add_vhost ${vhost_name}
    rabbitmqctl set_policy -p ${vhost_name} ha "^" '{"ha-mode":"all","ha-sync-mode":"automatic"}' | grep "Setting policy"
    CHECK_RESULT $?
    rabbitmqctl list_policies -p ${vhost_name} | grep "${vhost_name}"
    CHECK_RESULT $?
    rabbitmqctl clear_policy -p ${vhost_name} ha | grep "${vhost_name}"
    CHECK_RESULT $?
    rabbitmqctl eval "rabbit_amqqueue:declare({resource, <<\"${vhost_name}\">>, queue, <<\"test-queue\">>}, true, false, [], none, \"test\")."
    rabbitmqctl list_queues -p ${vhost_name} | grep "test-queue"
    CHECK_RESULT $?
    rabbitmqctl list_queues -p ${vhost_name} --offline | grep "test-queue"
    CHECK_RESULT $? 1 0
    rabbitmqctl list_queues -p ${vhost_name} --online | grep "test-queue"
    CHECK_RESULT $?
    rabbitmqctl list_queues -p ${vhost_name} --local | grep "test-queue"
    CHECK_RESULT $?
    rabbitmqctl list_exchanges -p ${vhost_name} name type | grep "topic"
    CHECK_RESULT $?
    rabbitmqctl list_bindings -p ${vhost_name} | grep "exchang"
    CHECK_RESULT $?
    rabbitmqctl list_connections | grep "connections"
    CHECK_RESULT $?
    rabbitmqctl list_channels | grep "channels"
    CHECK_RESULT $?
    rabbitmqctl list_consumers | grep "consumers"
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
