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
    source /usr/lib/rabbitmq/bin/rabbitmq-defaults >/dev/null 2>&1
    CHECK_RESULT $?
    echo "$CONF_ENV_FILE" | grep "/etc/rabbitmq/rabbitmq-env.conf"
    CHECK_RESULT $?
    systemctl start rabbitmq-server
    CHECK_RESULT $?
    systemctl status rabbitmq-server | grep "active (running)"
    CHECK_RESULT $?
    systemctl stop rabbitmq-server
    CHECK_RESULT $?
    systemctl status rabbitmq-server | grep "inactive (dead)"
    CHECK_RESULT $?
    rabbitmq-server -detached 2>&1 | xargs | grep "PID file not written; -detached was passed." | grep "ERROR"
    CHECK_RESULT $? 1 0
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop rabbitmq-server
    DNF_REMOVE
    rm -rf result /var/lib/rabbitmq/
    kill -9 $(pgrep -u rabbitmq)
    which firewalld && systemctl start firewalld
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
