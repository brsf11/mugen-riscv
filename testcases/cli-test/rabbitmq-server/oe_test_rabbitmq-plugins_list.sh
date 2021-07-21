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
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    rabbitmq-plugins list | grep "running on rabbit"
    CHECK_RESULT $?
    rabbitmq-plugins enable rabbitmq_management
    rabbitmq-plugins list -E | grep "\[E"
    CHECK_RESULT $?
    rabbitmq-plugins list -e | grep -i "\[e"
    CHECK_RESULT $?
    rabbitmq-plugins list -m | grep "Listing plugins with pattern"
    CHECK_RESULT $?
    rabbitmq-plugins list -v | grep "Description"
    CHECK_RESULT $?
    rabbitmq-plugins list web | grep "rabbitmq_web"
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rabbitmq-plugins disable rabbitmq_management
    systemctl stop rabbitmq-server
    DNF_REMOVE
    rm -rf /var/lib/rabbitmq/
    which firewalld && systemctl start firewalld
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
