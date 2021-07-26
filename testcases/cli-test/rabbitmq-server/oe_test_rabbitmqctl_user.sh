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
    user_mq="test"
    passwd_mq="test"
    newpasswd_mq="newtest"
    which firewalld && systemctl stop firewalld
    systemctl restart rabbitmq-server
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    rabbitmqctl add_user ${user_mq} ${passwd_mq} | grep "${user_mq}"
    CHECK_RESULT $?
    rabbitmqctl authenticate_user ${user_mq} ${passwd_mq} | grep "${user_mq}"
    CHECK_RESULT $?
    rabbitmqctl set_user_tags ${user_mq} administrator | grep "${user_mq}"
    CHECK_RESULT $?
    rabbitmqctl set_user_tags ${user_mq} | grep "${user_mq}"
    CHECK_RESULT $?
    rabbitmqctl list_users | grep ${user_mq}
    CHECK_RESULT $?
    rabbitmqctl change_password ${user_mq} ${newpasswd_mq} | grep "${user_mq}"
    CHECK_RESULT $?
    rabbitmqctl clear_password ${user_mq} | grep "${user_mq}"
    CHECK_RESULT $?
    rabbitmqctl delete_user ${user_mq} | grep "${user_mq}"
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
