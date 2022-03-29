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
# @Date      :   2020.4.27
# @License   :   Mulan PSL v2
# @Desc      :   FTP transfer file deleted
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    SSH_CMD "yum install -y vsftpd firewalld;systemctl start vsftpd;systemctl start firewalld;
    chmod -R 777 /var/ftp/pub;cd /var/ftp/pub;touch delete_file1.txt;touch delete_file2.txt;" \
        ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "cp /etc/vsftpd/ftpusers /etc/vsftpd/ftpusers.bak;sed -i /root/d /etc/vsftpd/ftpusers;
    echo \\\"#root\\\" >> /etc/vsftpd/ftpusers" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "cp /etc/vsftpd/user_list /etc/vsftpd/user_list.bak;sed -i /root/d /etc/vsftpd/user_list;
    echo \\\"#root\\\" >> /etc/vsftpd/user_list" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "firewall-cmd --add-service=ftp --permanent;firewall-cmd --reload;systemctl restart vsftpd;
    setsebool -P ftpd_full_access=on" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    DNF_INSTALL ftp
    setsebool -P ftpd_full_access=on
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    expect <<EOF
    log_file testlog
    spawn ftp ${NODE2_IPV4}
    expect {
        "Name*):" {send "root\r";
        expect "Password:" {send "${NODE2_PASSWORD}\r"}
        exp_continue
        }
        "ftp>" {send "cd /var/ftp/pub/\r";
        expect "ftp>" {send "delete delete_file1.txt\r"}
        expect "ftp>" {send "bye\r"}
        exp_continue
        }
    }
EOF
    grep "230 Login successful" testlog
    CHECK_RESULT $?
    grep "221 Goodbye" testlog
    CHECK_RESULT $?
    SSH_CMD "ls /var/ftp/pub/ > /tmp/file_list" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_SCP ${NODE2_USER}@${NODE2_IPV4}:/tmp/file_list . ${NODE2_PASSWORD}
    ! grep "delete_file1.txt" file_list && grep "delete_file2.txt" file_list
    CHECK_RESULT $?
    rm -rf file_list
    expect <<EOF
    log_file testlog1
    spawn ftp ${NODE2_IPV4}
    expect {
        "Name*):" {send "root\r";
        expect "Password:" {send "${NODE2_PASSWORD}\r"}
        exp_continue
        }
        "ftp>" {send "cd /var/ftp/pub/\r";
        expect "ftp>" {send "prompt off\r"}
        expect "ftp>" {send "mdelete delete*.txt\r"}
        expect "ftp>" {send "bye\r"}
        exp_continue
        }
    }
EOF
    grep "230 Login successful" testlog1
    CHECK_RESULT $?
    grep "221 Goodbye" testlog1
    CHECK_RESULT $?
    SSH_CMD "ls /var/ftp/pub/ > /tmp/file_list" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_SCP ${NODE2_USER}@${NODE2_IPV4}:/tmp/file_list . ${NODE2_PASSWORD}
    grep "delete*.txt" file_list
    CHECK_RESULT $? 1
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    SSH_CMD "mv /etc/vsftpd/ftpusers.bak /etc/vsftpd/ftpusers;mv /etc/vsftpd/user_list.bak /etc/vsftpd/user_list;
    yum remove -y vsftpd" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    rm -rf file_list delete_file[1-2].txt testlog*
    LOG_INFO "Finish environment cleanup."
}

main $@
