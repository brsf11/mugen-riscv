#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   wenjun
# @Contact   :   1009065695@qq.com
# @Date      :   2021.12.30
# @License   :   Mulan PSL v2
# @Desc      :   ha prepare
# ############################################

source "../common/common_lib.sh"

function ha_pre() {
    systemctl stop firewalld
    systemctl disable firewalld
    flag=false
    if [ $(getenforce | grep Enforcing) ]; then
        setenforce 0
        P_SSH_CMD --node 2 --cmd "setenforce 0"
        flag=true
    fi
    DNF_INSTALL "corosync pacemaker pcs"
    hostname=$(hostname)
    hostnamectl set-hostname ha1
    cp /etc/hosts /etc/hosts_bak
    echo "${NODE1_IPV4} ha1
${NODE2_IPV4} ha2" >> /etc/hosts
    echo "${NODE1_PASSWORD}" | passwd --stdin hacluster
    echo "totem {
        version: 2
        cluster_name: hacluster
        crypto_cipher: none
        crypto_hash: none
}
logging {         
        fileline: off
        to_stderr: yes
        to_logfile: yes
        logfile: /var/log/cluster/corosync.log
        to_syslog: yes
        debug: off
        logger_subsys {
               subsys: QUORUM
               debug: off
        }
}
quorum {
        provider: corosync_votequorum
        two_node: 1
}
nodelist {
        node {
               name: ha1
               nodeid: 1
               ring0_addr: ${NODE1_IPV4}
        }
        node {
               name: ha2
               nodeid: 2
               ring0_addr: ${NODE2_IPV4} 
        }
}" > /etc/corosync/corosync.conf
    P_SSH_CMD --node 2 --cmd "
    systemctl stop firewalld;
    systemctl disable firewalld;
    dnf install -y corosync pacemaker pcs;
    hostnamectl set-hostname ha2;
    echo ${NODE1_PASSWORD} | passwd --stdin hacluster;
    mv /etc/hosts /etc/hosts_bak"
    SSH_SCP /etc/hosts ${NODE2_USER}@${NODE2_IPV4}:/etc/ "${NODE2_PASSWORD}"
    SSH_SCP /etc/corosync/corosync.conf ${NODE2_USER}@${NODE2_IPV4}:/etc/corosync/ "${NODE2_PASSWORD}"
    systemctl start pcsd
    systemctl start pacemaker
    pcs property set stonith-enabled=false
    pcs property set no-quorum-policy=stop
    crm_verify -L
    systemctl start corosync
    P_SSH_CMD --node 2 --cmd "
    systemctl start pcsd;
    systemctl start pacemaker;
    pcs property set stonith-enabled=false;
    pcs property set no-quorum-policy=stop;
    crm_verify -L;
    systemctl start corosync"
    cat > /root/hacluster <<EOF
hacluster
${NODE1_PASSWORD}
EOF
    pcs host auth ha1 ha2 < /root/hacluster
    systemctl restart pacemaker
    systemctl restart corosync
    systemctl restart pcsd
    P_SSH_CMD --node 2 --cmd "
    systemctl restart pacemaker;
    systemctl restart corosync;
    systemctl restart pcsd"
}

function ha_post() {
    systemctl stop corosync
    systemctl stop pacemaker
    systemctl stop pcsd
    rm -rf /etc/hosts /etc/corosync/corosync.conf
    mv /etc/hosts_bak /etc/hosts
    hostnamectl set-hostname ${hostname}
    DNF_REMOVE
    if [ ${flag} = 'true' ]; then
        setenforce 1
        P_SSH_CMD --node 2 --cmd "setenforce 1"
    fi
    systemctl start firewalld
    systemctl enable firewalld
    P_SSH_CMD --node 2 --cmd "
    systemctl stop corosync;
    systemctl stop pacemaker;
    systemctl stop pcsd;
    rm -rf /etc/hosts /etc/corosync/corosync.conf;
    mv /etc/hosts_bak /etc/hosts;
    hostnamectl set-hostname ${hostname};
    dnf remove -y corosync pacemaker pcs;
    systemctl start firewalld;
    systemctl enable firewalld"
}

