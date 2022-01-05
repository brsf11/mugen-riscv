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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-4-10
# @License   :   Mulan PSL v2
# @Desc      :   FTP File transfer-network delay packet loss
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    remote_eth1=$(SSH_CMD "ip route | grep ${NODE2_IPV4} | awk '{print\$3}'" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER} | tail -n 1 | tr '\r' ' ')
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    SSH_CMD "yum install -y vsftpd;systemctl start vsftpd;chmod -R 777 /var/ftp/pub;
    cd /var/ftp/pub;touch download_file1.txt download_file2.txt;
    cp /etc/vsftpd/ftpusers /etc/vsftpd/ftpusers.bak;sed -i /root/d /etc/vsftpd/ftpusers;echo \\\"#root\\\" >> /etc/vsftpd/ftpusers;
    cp /etc/vsftpd/user_list /etc/vsftpd/user_list.bak;sed -i /root/d /etc/vsftpd/user_list;echo \\\"#root\\\" >> /etc/vsftpd/user_list;
    systemctl restart vsftpd;" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    DNF_INSTALL ftp
    setsebool -P ftpd_full_access=on
    SSH_CMD "setsebool -P ftpd_full_access=on" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    SSH_CMD "tc qdisc add dev ${remote_eth1} root netem loss 20%" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    ftp -n ${NODE2_IPV4} >log <<EOF
user root ${NODE2_PASSWORD}
cd /var/ftp/pub/
prompt
mget *.*
EOF
    CHECK_RESULT $?
    grep -iE 'error|fail' log
    CHECK_RESULT $? 1
    find download_file1.txt && find download_file2.txt
    CHECK_RESULT $?
    SSH_CMD "tc qdisc del dev ${remote_eth1} root netem loss 20%" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    SSH_CMD "mv /etc/vsftpd/ftpusers.bak /etc/vsftpd/ftpusers;mv /etc/vsftpd/user_list.bak /etc/vsftpd/user_list;
    cd /var/ftp/pub;rm -rf download_file1.txt download_file2.txt;yum remove -y vsftpd" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    rm -rf download_file[1-2].txt log
    DNF_REMOVE ftp
    LOG_INFO "End to restore the test environment."
}

main $@
