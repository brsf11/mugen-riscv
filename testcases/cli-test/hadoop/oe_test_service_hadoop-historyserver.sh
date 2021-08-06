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
# @Desc      :   Test hadoop-historyserver.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    common_path=$(
        cd "$(dirname "$0")" || exit 1
        cd common || exit 1
        pwd
    )
    host_name=$(hostname)
    name_host=HadoopX
    hostname | grep -i ${name_host} || hostnamectl set-hostname ${name_host}2
    DNF_INSTALL "hadoop-hdfs hadoop-mapreduce hadoop-yarn  java-1.8.0-openjdk apache-zookeeper"
    echo "export JAVA_HOME=/usr/lib/jvm/jre" >>/usr/libexec/hadoop-layout.sh
    sed -i "/Group=hadoop/a SuccessExitStatus=143" /usr/lib/systemd/system/hadoop-historyserver.service
    systemctl daemon-reload
    echo "${NODE1_IPV4} HadoopX2
    ${NODE2_IPV4} HadoopX1
    ${NODE3_IPV4} HadoopX" >>/etc/hosts
    rm -rf /tmp/hsperfdata* /tmp/hadoop* /opt/hadoop /var/lib/hadoop-hdfs
    SSH_CMD "
    hostname | grep -i ${name_host} || hostnamectl set-hostname ${name_host}1
    dnf -y install hadoop-hdfs hadoop-mapreduce hadoop-yarn  java-1.8.0-openjdk apache-zookeeper
    echo 'export JAVA_HOME=/usr/lib/jvm/jre' >>/usr/libexec/hadoop-layout.sh
    sed -i '/Group=hadoop/a SuccessExitStatus=143' /usr/lib/systemd/system/hadoop-historyserver.service
    systemctl daemon-reload
    echo '${NODE1_IPV4} HadoopX2
    ${NODE2_IPV4} HadoopX1
    ${NODE3_IPV4} HadoopX' >>/etc/hosts
    rm -rf /tmp/hsperfdata* /tmp/hadoop* /opt/hadoop /var/lib/hadoop-hdfs
    " "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    SSH_CMD "
    hostname | grep -i ${name_host} || hostnamectl set-hostname ${name_host}
    dnf -y install hadoop-hdfs hadoop-mapreduce hadoop-yarn  java-1.8.0-openjdk apache-zookeeper
    echo 'export JAVA_HOME=/usr/lib/jvm/jre' >>/usr/libexec/hadoop-layout.sh
    sed -i '/Group=hadoop/a SuccessExitStatus=143' /usr/lib/systemd/system/hadoop-historyserver.service
    systemctl daemon-reload
    echo '${NODE1_IPV4} HadoopX2
    ${NODE2_IPV4} HadoopX1
    ${NODE3_IPV4} HadoopX' >>/etc/hosts
    rm -rf /tmp/hsperfdata* /tmp/hadoop* /opt/hadoop /var/lib/hadoop-hdfs
    " "${NODE3_IPV4}" "${NODE3_PASSWORD}" "${NODE3_USER}"
    cp ./common/* /etc/hadoop/
    SSH_SCP "${common_path}/" "${NODE2_USER}@${NODE2_IPV4}:/tmp/" "${NODE2_PASSWORD}"
    SSH_SCP "${common_path}/" "${NODE3_USER}@${NODE3_IPV4}:/tmp/" "${NODE2_PASSWORD}"
    systemctl start zookeeper
    hadoop-daemon.sh start journalnode
    which firewalld && systemctl stop firewalld
    SSH_CMD "
    mv /tmp/common/* /etc/hadoop
    systemctl start zookeeper
    hadoop-daemon.sh start journalnode
    which firewalld && systemctl stop firewalld
    " "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    SSH_CMD "
    mv /tmp/common/* /etc/hadoop
    systemctl start zookeeper
    hadoop-daemon.sh start journalnode
    which firewalld && systemctl stop firewalld
    " "${NODE3_IPV4}" "${NODE3_PASSWORD}" "${NODE3_USER}"
    expect <<EOF
        spawn sudo -u hdfs hdfs namenode -format
        expect {
            "(Y or N)" {
                send "Y\r"
            }
        }
        expect eof
EOF
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution hadoop-historyserver.service
    test_reload hadoop-historyserver.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop hadoop-historyserver.service
    systemctl stop zookeeper
    hadoop-daemon.sh stop journalnode
    kill -9 $(pgrep -u journalnode)
    sed -i "/export JAVA_HOME=\/usr\/lib\/jvm\/jre/d" /usr/libexec/hadoop-layout.sh
    sed -i "/SuccessExitStatus=143/d" /usr/lib/systemd/system/hadoop-historyserver.service
    systemctl daemon-reload
    DNF_REMOVE
    sed -i "/${name_host}/d" /etc/hosts
    hostname | grep -i ${host_name} || hostnamectl set-hostname ${host_name}
    which firewalld && systemctl start firewalld
    rm -rf /tmp/hsperfdata* /tmp/hadoop* /opt/hadoop /var/lib/hadoop-hdfs
    SSH_CMD "
    systemctl stop zookeeper
    hadoop-daemon.sh stop journalnode
    kill -9 $(pgrep -u journalnode)
    sed -i '/export JAVA_HOME=\/usr\/lib\/jvm\/jre/d' /usr/libexec/hadoop-layout.sh
    sed -i '/SuccessExitStatus=143/d' /usr/lib/systemd/system/hadoop-historyserver.service
    systemctl daemon-reload
    dnf -y remove hadoop-hdfs hadoop-mapreduce hadoop-yarn  java-1.8.0-openjdk apache-zookeeper
    sed -i '/${name_host}/d' /etc/hosts
    hostname | grep -i ${host_name} || hostnamectl set-hostname ${host_name}
    which firewalld && systemctl start firewalld
    rm -rf /tmp/hsperfdata* /tmp/hadoop* /opt/hadoop /var/lib/hadoop-hdfs /tmp/common
    " "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    SSH_CMD "
    systemctl stop zookeeper
    hadoop-daemon.sh stop journalnode
    kill -9 $(pgrep -u journalnode)
    sed -i '/export JAVA_HOME=\/usr\/lib\/jvm\/jre/d' /usr/libexec/hadoop-layout.sh
    sed -i '/SuccessExitStatus=143/d' /usr/lib/systemd/system/hadoop-historyserver.service
    systemctl daemon-reload
    dnf -y remove hadoop-hdfs hadoop-mapreduce hadoop-yarn  java-1.8.0-openjdk apache-zookeeper
    sed -i '/${name_host}/d' /etc/hosts
    hostname | grep -i ${host_name} || hostnamectl set-hostname ${host_name}
    which firewalld && systemctl start firewalld
    rm -rf /tmp/hsperfdata* /tmp/hadoop* /opt/hadoop /var/lib/hadoop-hdfs /tmp/common
    " "${NODE3_IPV4}" "${NODE3_PASSWORD}" "${NODE3_USER}"
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
