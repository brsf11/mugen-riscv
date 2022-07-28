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
# @Date      :   2020-4-10
# @License   :   Mulan PSL v2
# @Desc      :   Enables users to share directories on Samba servers
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    SSH_CMD "yum install -y samba policycoreutils-python-utils; grep 'example' /etc/group || groupadd example;
    sed -i '/testsamba/d' /etc/security/opasswd;useradd testsamba;
    (echo ${NODE1_PASSWORD};echo ${NODE1_PASSWORD}) | smbpasswd -a testsamba -s" \
        ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "test -d /tmp/testsamba || mkdir -p /tmp/testsamba;
    test -d /var/lib/samba/usershares/ || mkdir -p /var/lib/samba/usershares/;
    chgrp example /var/lib/samba/usershares/;chmod 1770 /var/lib/samba/usershares/" \
        ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "cp -a /etc/samba/smb.conf /etc/samba/smb.conf.bak;echo  \\\" \\\" >> /etc/samba/smb.conf;
    echo  \\\"\\[example\\]\\\" >> /etc/samba/smb.conf;echo  \\\"\\tpath = /tmp/testsamba\\\" >> /etc/samba/smb.conf;
    echo  \\\"\\tread only = no\\\" >> /etc/samba/smb.conf;
    sed -i \\\"/\\[global\\]/a \\tusershare path = /var/lib/samba/usershares/\\\" /etc/samba/smb.conf;
    sed -i \\\"/\\[global\\]/a \\tusershare max shares = 100\\\" /etc/samba/smb.conf;
    sed -i \\\"/\\[global\\]/a \\tusershare prefix allow list = /data /srv\\\" /etc/samba/smb.conf" \
        ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "systemctl stop firewalld; smbcontrol all reload-config;systemctl restart smb || systemctl start smb;systemctl enable smb;
    setsebool -P samba_export_all_ro on;setsebool -p samba_export_all_rw on" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
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
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /home/client
    rmdir /home/client
    SSH_CMD "systemctl stop smb; rm -f /etc/samba/smb.conf;mv /etc/samba/smb.conf.bak /etc/samba/smb.conf;
    yum remove samba policycoreutils-python-utils -y;userdel -r testsamba;groupdel example; 
    rm -rf /tmp/testsamba;rm -rf /var/lib/samba/usershares/; systemctl start firewalld" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
