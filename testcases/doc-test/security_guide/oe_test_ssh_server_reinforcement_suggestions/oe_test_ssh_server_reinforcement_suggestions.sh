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
# @Author    :   wangxiaoya
# @Contact   :   wangxiaoya@qq.com
# @Date      :   2022/6/13
# @License   :   Mulan PSL v2
# @Desc      :   Suggestions on server SSH reinforcement
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function run_test() {
    LOG_INFO "Start executing testcase."
    grep "^Protocol 2" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^SyslogFacility AUTH" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^LogLevel VERBOSE" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^X11Forwarding no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^#MaxAuthTries" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^PubkeyAuthentication yes" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^RSAAuthentication yes" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^IgnoreRhosts yes" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^RhostsRSAAuthentication no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^HostbasedAuthentication no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^PermitRootLogin yes" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^PermitEmptyPasswords no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^PermitUserEnvironment no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^#ClientAliveCountMax" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^Banner /etc/issue.net" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^MACs hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^StrictModes yes" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^UsePAM yes" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^AllowTcpForwarding no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^Subsystem sftp /usr/libexec/openssh/sftp-server -l INFO -f AUTH" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^AllowAgentForwarding no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^GatewayPorts no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^PermitTunnel no" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    grep "^#LoginGraceTime 2m" /etc/ssh/sshd_config
    CHECK_RESULT $? 0 0 "No safety reinforcement."
    LOG_INFO "Finish testcase execution."
}

main "$@"
