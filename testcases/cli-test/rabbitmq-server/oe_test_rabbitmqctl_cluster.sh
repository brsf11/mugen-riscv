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
    cluster_name="mycluster"
    host_name=$(hostname)
    name_host=rabbitmq
    name_host_1=rabbitmq1
    name_host_2=rabbitmq2
    DNF_INSTALL rabbitmq-server
    which firewalld && systemctl stop firewalld
    sed -i "/${name_host}/d" /etc/hosts
    hostname | grep -i ${name_host} || hostnamectl set-hostname ${name_host_1}
    export NODENAME=rabbit@${name_host_1}
    echo -e "${NODE1_IPV4}" "${name_host_1}" >>/etc/hosts
    echo -e "${NODE2_IPV4}" "${name_host_2}" >>/etc/hosts
    systemctl restart rabbitmq-server
    cookie_erlang=$(cat /var/lib/rabbitmq/.erlang.cookie)
    SSH_CMD "
    dnf install -y rabbitmq-server
    which firewalld && systemctl stop firewalld
    sed -i '/${name_host}/d' /etc/hosts
    hostname | grep -i ${name_host} || hostnamectl set-hostname ${name_host_2}
    export NODENAME=rabbit@${name_host_2}
    echo -e ${NODE1_IPV4} ${name_host_1} >>/etc/hosts
    echo -e ${NODE2_IPV4} ${name_host_2} >>/etc/hosts
    echo ${cookie_erlang} > /var/lib/rabbitmq/.erlang.cookie
    chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie
    chmod 400 /var/lib/rabbitmq/.erlang.cookie
    systemctl  restart rabbitmq-server
    " "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    rabbitmqctl stop_app
    rabbitmqctl join_cluster rabbit@${name_host_2} | grep "Clustering node"
    CHECK_RESULT $?
    rabbitmqctl start_app
    rabbitmqctl cluster_status | grep rabbit@${name_host_1} | grep rabbit@${name_host_2}
    CHECK_RESULT $?
    rabbitmqctl -n rabbit@${name_host_2} stop_app
    rabbitmqctl forget_cluster_node rabbit@${name_host_2} | grep "Removing node"
    CHECK_RESULT $?
    rabbitmqctl -n rabbit@${name_host_2} reset
    rabbitmqctl -n rabbit@${name_host_2} start_app
    rabbitmqctl cluster_status | grep rabbit@${name_host_1} | grep rabbit@${name_host_2}
    CHECK_RESULT $? 1 0
    rabbitmqctl stop_app
    rabbitmqctl join_cluster rabbit@${name_host_2} --ram | grep "Clustering node"
    CHECK_RESULT $?
    rabbitmqctl start_app
    rabbitmqctl cluster_status | grep rabbit@${name_host_1} | grep rabbit@${name_host_2}
    CHECK_RESULT $?
    rabbitmqctl stop_app
    rabbitmqctl change_cluster_node_type disc | grep "disc node"
    CHECK_RESULT $?
    rabbitmqctl start_app
    rabbitmqctl cluster_status | grep "disc"
    CHECK_RESULT $?
    systemctl restart rabbitmq-server
    rabbitmqctl stop_app
    rabbitmqctl update_cluster_nodes rabbit@${name_host_2} | grep "seed"
    CHECK_RESULT $?
    rabbitmqctl force_boot
    CHECK_RESULT $?
    rabbitmqctl start_app | grep "Starting node"
    CHECK_RESULT $?
    rabbitmqctl set_cluster_name ${cluster_name} | grep "${cluster_name}"
    CHECK_RESULT $?
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop rabbitmq-server
    kill -9 "$(pgrep -f erlang)"
    sed -i "/${name_host}/d" /etc/hosts
    hostnamectl set-hostname "${host_name}"
    kill -9 $(pgrep -u rabbitmq)
    DNF_REMOVE
    rm -rf /var/lib/rabbitmq/ /var/log/rabbitmq
    which firewalld && systemctl start firewalld
    SSH_CMD "
    systemctl  stop rabbitmq-server
    sed -i '/${name_host}/d' /etc/hosts
    hostnamectl set-hostname '${host_name}'
    dnf remove -y rabbitmq-server
    rm -rf /var/lib/rabbitmq/ /var/log/rabbitmq
    which firewalld && systemctl start firewalld
    " "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
