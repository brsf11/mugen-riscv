#!/usr/bin/bash
#Copyright (c) 2022. Huawei Technologies Co.,Ltd.
##############################################
#@CaseName:   oe_test_storage_smb_host_share
#@Author:     Classicriver_jia
#@Contact:    classicriver_jia@foxmail.com
#@Date:       2020-4-10
#@License:    Mulan PSL v2
#@Desc:       SMB configuration host based shared access
##############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    SSH_CMD "yum install -y samba policycoreutils-python-utils; sed -i '/testsamba/d' /etc/security/opasswd;useradd testsamba;
	(echo ${NODE1_PASSWORD};echo ${NODE1_PASSWORD}) | smbpasswd -a testsamba -s" \
        ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "cp -a /etc/hosts /etc/hosts.bak;echo  \\\" \\\" >> /etc/hosts;
	echo \\\"${NODE1_IPV4} client1.example.com\\\" >>/etc/hosts;
	echo \\\"${NODE2_IPV4} client2.example.com\\\" >>/etc/hosts" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "test -d /tmp/testsamba || mkdir -p /tmp/testsamba" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "cp -a /etc/samba/smb.conf /etc/samba/smb.conf.bak;echo  \\\" \\\" >> /etc/samba/smb.conf;
	echo  \\\"\\[testsamba\\]\\\" >> /etc/samba/smb.conf;echo  \\\"\\tcomment = public stuff\\\" >> /etc/samba/smb.conf;
	echo  \\\"\\tpath = /home/testsamba\\\" >> /etc/samba/smb.conf;
	echo  \\\"\\thosts allow = 127.0.0.1 client1.example.com\\\" >> /etc/samba/smb.conf;
	echo  \\\"\\thosts deny = client2.example.com\\\" >> /etc/samba/smb.conf" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "systemctl stop firewalld; systemctl restart smb || systemctl start smb;systemctl enable smb;
	setsebool -P samba_export_all_ro on;setsebool -P samba_export_all_rw on" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
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
    yum remove samba policycoreutils-python-utils -y; userdel -r testsamba; systemctl start firewalld" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    DNF_REMOVE
    systemctl start firewalld
    LOG_INFO "Finish environment cleanup."
}

main $@
