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
# @Desc      :   Common Samba command line utilities-smbclient
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
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
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    expect -c "
        set timeout 30
        log_file testlog
        spawn smbclient -U testsamba //${NODE2_IPV4}/testsamba
		expect \"*assword*\" {send \"${NODE2_PASSWORD}\\r\";
		expect \"smb*>\" {send \"ls\\r\";
		expect \"smb*>\" {send \"exit\\r\"}}}
        expect eof
	"
    grep -iE "error|fail" testlog
    CHECK_RESULT $? 1
    smbclient -L ${NODE2_IPV4} -U testsamba%${NODE2_PASSWORD}
    CHECK_RESULT $?
    smbclient -c "ls" //${NODE2_IPV4}/testsamba -U testsamba%${NODE2_PASSWORD}
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    SSH_CMD "systemctl stop smb; rm -f /etc/samba/smb.conf;mv /etc/samba/smb.conf.bak /etc/samba/smb.conf;
    yum remove samba -y; userdel -r testsamba; systemctl stop firewalld" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    DNF_REMOVE
    rm -rf testlog
    systemctl start firewalld
    LOG_INFO "Finish environment cleanup."
}

main $@
