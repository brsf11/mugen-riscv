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
    vhost_name="myvhost"
    which firewalld && systemctl stop firewalld
    systemctl restart rabbitmq-server
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    rabbitmqctl add_vhost ${vhost_name} | grep "${vhost_name}"
    CHECK_RESULT $?
    grep -r "myvhost" /var/lib/rabbitmq/mnesia/ --binary-files=without-match
    CHECK_RESULT $?
    rabbitmqctl list_vhosts name tracing | grep ${vhost_name}
    CHECK_RESULT $?
    rabbitmqctl add_user ${user_mq} ${passwd_mq}
    rabbitmqctl set_permissions -p ${vhost_name} ${user_mq} "^${user_mq}-.*" ".*" ".*" | grep "${vhost_name}"
    CHECK_RESULT $?
    rabbitmqctl list_permissions -p ${vhost_name} | grep "${user_mq}"
    CHECK_RESULT $?
    rabbitmqctl list_user_permissions ${user_mq} | grep "${vhost_name}"
    CHECK_RESULT $?
    rabbitmqctl clear_permissions -p ${vhost_name} ${user_mq} | grep "${vhost_name}"
    CHECK_RESULT $?
    rabbitmqctl delete_vhost ${vhost_name} | grep "${vhost_name}"
    CHECK_RESULT $?
    grep -r "myvhost" /var/lib/rabbitmq/mnesia/ --binary-files=without-match
    CHECK_RESULT $? 0 1
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
