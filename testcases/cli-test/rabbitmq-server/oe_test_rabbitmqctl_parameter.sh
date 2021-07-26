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
    user_mq="test"
    passwd_mq="test"
    DNF_INSTALL rabbitmq-server
    which firewalld && systemctl stop firewalld
    systemctl restart rabbitmq-server
    rabbitmqctl add_vhost ${vhost_name}
    rabbitmqctl add_user ${user_mq} ${passwd_mq}
    rabbitmqctl eval 'rabbit_amqqueue:declare({resource, <<"/">>, queue, <<"test-queue">>}, true, false, [], none, "test").'
    rabbitmqctl eval "rabbit_amqqueue:declare({resource, <<\"${vhost_name}\">>, queue, <<\"test-queue\">>}, true, false, [], none, \"test\")."
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    rabbitmqctl purge_queue test-queue | grep "Purging queue"
    CHECK_RESULT $?
    rabbitmq-plugins enable rabbitmq_federation_management
    rabbitmqctl set_parameter federation-upstream test '{"uri":"amqp://test:test@127.0.0.1:51672","ack-mode":"on-confirm"}' | grep "Setting runtime parameter"
    CHECK_RESULT $?
    rabbitmqctl list_parameters | grep "test"
    CHECK_RESULT $?
    rabbitmqctl clear_parameter federation-upstream test | grep "Clearing runtime paramete"
    CHECK_RESULT $?
    rabbitmqctl list_parameters | grep "test"
    CHECK_RESULT $? 1 0
    rabbitmqctl set_global_parameter mqtt_default_vhosts '{"O=client,CN=guest":"/"}' | grep "Setting global runtime parameter"
    CHECK_RESULT $?
    rabbitmqctl list_global_parameters | grep "mqtt_default_vhosts"
    CHECK_RESULT $?
    rabbitmqctl clear_global_parameter mqtt_default_vhosts | grep "Clearing global runtime parameter"
    CHECK_RESULT $?
    rabbitmqctl list_global_parameters | grep "mqtt_default_vhosts"
    CHECK_RESULT $? 1 0
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
