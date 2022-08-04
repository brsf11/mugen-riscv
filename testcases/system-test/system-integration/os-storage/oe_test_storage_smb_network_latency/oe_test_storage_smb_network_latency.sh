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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-5-8
# @License   :   Mulan PSL v2
# @Desc      :   SMB network latency
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    remote_eth1=$(SSH_CMD "ip route | grep ${NODE2_IPV4} | awk '{print\$3}'" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER} | tail -n 1 | tr '\r' ' ')
    remote_eth1=$(echo ${remote_eth1})
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environment preparation."
    SSH_CMD "yum install -y samba; sed -i '/testsamba/d' /etc/security/opasswd;useradd testsamba;
	(echo ${NODE1_PASSWORD};echo ${NODE1_PASSWORD}) | smbpasswd -a testsamba -s" \
        ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "cp -a /etc/samba/smb.conf /etc/samba/smb.conf.bak;echo  \\\" \\\" >> /etc/samba/smb.conf;
	echo  \\\"\\[testsamba\\]\\\" >> /etc/samba/smb.conf;echo  \\\"\\tcomment = public stuff\\\" >> /etc/samba/smb.conf;
	echo  \\\"\\tpath = /home/testsamba\\\" >> /etc/samba/smb.conf" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "systemctl start smb;systemctl enable smb;systemctl stop firewalld;
	setsebool samba_export_all_ro on;setsebool samba_export_all_rw on;chmod 755 /home/testsamba" \
        ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    DNF_INSTALL cifs-utils
    systemctl stop firewalld
    mkdir -p /home/client
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    mount -t cifs -o username=testsamba,password=${NODE1_PASSWORD} //${NODE2_IPV4}/testsamba /home/client
    CHECK_RESULT $?
    df -h | grep -i '/home/client' | grep "${NODE2_IPV4}"
    CHECK_RESULT $?
    SSH_CMD "tc qdisc add dev ${remote_eth1} root netem delay 300ms" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    SSH_CMD "echo "hello" > /home/testsamba/test;chmod 755 /home/testsamba/test" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    grep "hello" /home/client/test
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /home/client
    rmdir /home/client
    SSH_CMD "tc qdisc del dev ${remote_eth1} root netem delay 300ms; systemctl stop smb;
    rm -f /etc/samba/smb.conf;mv /etc/samba/smb.conf.bak /etc/samba/smb.conf;yum remove samba -y;
    userdel -r testsamba; systemctl start firewalld" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    DNF_REMOVE
    systemctl start firewalld
    LOG_INFO "Finish environment cleanup."
}

main $@
