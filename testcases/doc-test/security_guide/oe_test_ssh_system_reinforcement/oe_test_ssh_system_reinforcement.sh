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
# @Desc      :   sshd system reinforcement test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start environmental preparation."
    grep "^SyslogFacility AUTH" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "SyslogFacility is not AUTH"
    grep "^LogLevel VERBOSE" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "LogLevel is not VERBOSE"
    grep "^X11Forwarding no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "X11Forwarding is not no"
    grep "^IgnoreRhosts yes" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "IgnoreRhosts is not yes"
    grep "^RhostsRSAAuthentication no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "RhostsRSAAuthentication is not no"
    grep "^Subsystem sftp /usr/libexec/openssh/sftp-server -l INFO -f AUTH" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "grep 'Subsystem sftp /usr/libexec/openssh/sftp-server -l INFO -f AUTH' failed"
    grep "^HostbasedAuthentication no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "HostbasedAuthentication is not no"
    grep "^Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "grep 'Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com' failed"
    grep "^ClientAliveCountMax 0" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "ClientAliveCountMax is not 0"
    grep "^MACs hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "grep 'MACs hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com' failed"
    grep "^AllowTcpForwarding no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "AllowTcpForwarding is not no"
    grep "^Subsystem sftp" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "Subsystem is not sftp"
    grep "^GatewayPorts no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "GatewayPorts is not no"
    grep "^PermitTunnel no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "PermitTunnel is not no"
    grep "^KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1,diffie-hellman-group-exchange-sha256" /etc/ssh/sshd_config || grep "^KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "grep KexAlgorithms failed"
    LOG_INFO "End of environmental preparation!"
}

main "$@"
