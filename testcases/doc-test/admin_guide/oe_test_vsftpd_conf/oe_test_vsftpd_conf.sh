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
# @Desc      :   Configuring VSFTPD
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "vsftpd ftp"
    systemctl start vsftpd
    useradd -m ftpuser1
    echo ${NODE1_PASSWORD} | passwd --stdin ftpuser1
    useradd -m ftpuser2
    echo ${NODE1_PASSWORD} | passwd --stdin ftpuser2
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
    echo "use_localtime=YES" >>/etc/vsftpd/vsftpd.conf
    systemctl restart vsftpd
    systemctl enable vsftpd
    systemctl status vsftpd | grep running
    CHECK_RESULT $?

    echo "banner_file=/etc/vsftpd/welcome.txt" >>/etc/vsftpd/vsftpd.conf
    echo "Welcome to this FTP server!" >>/etc/vsftpd/welcome.txt

    echo "ftpuser2" >>/etc/vsftpd/user_list
    echo "ftpuser2" >>/etc/vsftpd/ftpusers
    systemctl restart vsftpd

    expect <<EOF
    log_file testlog
    spawn ftp localhost
    expect {
        "Name*):" {send "ftpuser1\r";
        expect "Password:" {send "${NODE1_PASSWORD}\r"}
        exp_continue
        }
        "ftp>" {send "pwd\r";
        expect "ftp>" {send "bye\r"}
        exp_continue
        }
    }
EOF
    grep "Welcome to this FTP server" testlog
    CHECK_RESULT $?
    grep "230 Login successful" testlog
    CHECK_RESULT $?
    grep 257 testlog | grep ftpuser1
    CHECK_RESULT $?
    grep "221 Goodbye" testlog
    CHECK_RESULT $?

    expect <<EOF
    log_file testlog1
    spawn ftp localhost
    expect {
        "Name*):" {send "ftpuser2\r";
        exp_continue
        }
        "ftp>" {send "pwd\r";
        expect "ftp>" {send "bye\r"}
        exp_continue
        }
    }
EOF
    grep "Welcome to this FTP server" testlog1
    CHECK_RESULT $?
    grep -i 'Login failed' testlog1
    CHECK_RESULT $?
    grep "530 Permission denied" testlog1
    CHECK_RESULT $?
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i "/ftpuser2/d" /etc/vsftpd/user_list
    sed -i "/ftpuser2/d" /etc/vsftpd/ftpusers
    mv /etc/vsftpd/vsftpd.conf.bak /etc/vsftpd/vsftpd.conf
    DNF_REMOVE
    userdel -r ftpuser1
    userdel -r ftpuser2
    rm -rf testlog*
    LOG_INFO "Finish environment cleanup."
}

main $@
