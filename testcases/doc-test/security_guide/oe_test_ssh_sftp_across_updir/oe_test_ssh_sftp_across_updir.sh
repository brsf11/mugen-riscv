#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2020/5/28
# @License   :   Mulan PSL v2
# @Desc      :   Restrict SFTP users to access up across directories
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config-bak
    grep "^sftpgroup:" /etc/group && groupdel sftpgroup
    grep "^sftpuser:" /etc/passwd && userdel -rf sftpuser
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    groupadd sftpgroup
    CHECK_RESULT $?
    mkdir /sftp
    chown root:root /sftp
    chmod 755 /sftp
    ls -l / | grep sftp | grep "root root" | grep 'drwxr-xr-x'
    CHECK_RESULT $?
    useradd -g sftpgroup -s /sbin/nologin sftpuser
    grep "^sftpuser" /etc/passwd | grep "/sbin/nologin"
    CHECK_RESULT $?
    passwd sftpuser <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    mkdir /sftp/sftpuser
    chown root:root /sftp/sftpuser
    chmod 755 /sftp/sftpuser
    ls -l /sftp | grep sftpuser | grep "root root" | grep 'drwxr-xr-x'
    CHECK_RESULT $?
    sed -i 's/Subsystem sftp \/usr\/libexec\/openssh\/sftp-server -l INFO -f AUTH/Subsystem sftp internal-sftp -l INFO -f AUTH/g' /etc/ssh/sshd_config
    echo -e "Match Group sftpgroup\\n    ChrootDirectory /sftp/%u\\n    ForceCommand internal-sftp" >>/etc/ssh/sshd_config
    systemctl restart sshd
    expect <<EOF
        set timeout 15
        log_file testlog
        spawn ssh sftpuser@${NODE1_IPV4}
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "password" {
                send "${NODE1_PASSWORD}\\r"
            }
        }
        expect eof
EOF
    grep "This service allows sftp connections only" testlog
    CHECK_RESULT $?
    expect <<EOF
        set timeout 15
        log_file /home/sftpuser/testlog1
        spawn sftp sftpuser@${NODE1_IPV4}
        expect {
            "*yes/no*" {
                send "yes\\r"
            }
        }
        expect {
            "password" {
                send "${NODE1_PASSWORD}\\r"
            }
        }
        expect {
            "sftp>" {
                send "cd /sftp\\r"
            }
        }
        expect eof
EOF
    grep "stat remote file: No such file or directory" /home/sftpuser/testlog1
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "Start cleanning environment."
    userdel -rf sftpuser
    groupdel sftpgroup
    rm -rf testlog /sftp /run/faillock/sftpuser
    mv -f /etc/ssh/sshd_config-bak /etc/ssh/sshd_config
    systemctl restart sshd
    SLEEP_WAIT 10
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
