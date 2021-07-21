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
    setenforce 0
    which firewalld && systemctl stop firewalld
    systemctl restart rabbitmq-server
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    rabbitmq-plugins enable rabbitmq_web_mqtt
    CHECK_RESULT $?
    systemctl restart rabbitmq-server
    ss -ntl | grep 1883
    CHECK_RESULT $?
    rabbitmq-plugins disable rabbitmq_web_mqtt
    CHECK_RESULT $?
    systemctl restart rabbitmq-server
    ss -ntl | grep 1883
    CHECK_RESULT $? 0 1
    rabbitmq-plugins enable --offline rabbitmq_web_dispatch | grep "Offline change"
    CHECK_RESULT $?
    grep "rabbitmq_web_dispatch" /etc/rabbitmq/enabled_plugins
    CHECK_RESULT $?
    rabbitmq-plugins enable --online rabbitmq_web_mqtt | grep "started"
    CHECK_RESULT $?
    grep "rabbitmq_web_mqtt" /etc/rabbitmq/enabled_plugins
    CHECK_RESULT $?
    rabbitmq-plugins list web | grep "\[E\*\] rabbitmq_web_mqtt"
    CHECK_RESULT $?
    rabbitmq-plugins disable --offline rabbitmq_web_dispatch | grep "Offline change"
    CHECK_RESULT $?
    grep "rabbitmq_web_dispatch" /etc/rabbitmq/enabled_plugins
    CHECK_RESULT $? 1 0
    rabbitmq-plugins disable --online rabbitmq_web_mqtt | grep "stopped"
    CHECK_RESULT $?
    grep "rabbitmq_web_mqtt" /etc/rabbitmq/enabled_plugins
    CHECK_RESULT $? 1 0
    rabbitmq-plugins set rabbitmq_web_mqtt
    CHECK_RESULT $?
    systemctl restart rabbitmq-server
    ss -ntl | grep 1883
    CHECK_RESULT $?
    rabbitmq-plugins set --offline | grep "All plugins have been disabled"
    CHECK_RESULT $?
    systemctl restart rabbitmq-server
    ss -ntl | grep 1883
    CHECK_RESULT $? 0 1
    rabbitmq-plugins set --offline rabbitmq_web_dispatch | grep "set"
    CHECK_RESULT $?
    grep "rabbitmq_web_dispatch" /etc/rabbitmq/enabled_plugins
    CHECK_RESULT $?
    rabbitmq-plugins set --online rabbitmq_web_mqtt | grep "started"
    CHECK_RESULT $?
    grep "rabbitmq_web_mqtt" /etc/rabbitmq/enabled_plugins
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rabbitmq-plugins set
    systemctl stop rabbitmq-server
    DNF_REMOVE
    rm -rf /var/lib/rabbitmq/
    kill -9 $(pgrep -u rabbitmq)
    which firewalld && systemctl start firewalld
    setenforce 1
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
