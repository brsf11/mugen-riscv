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
# @Desc      :   FTP Transfer file-disk full
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function config_params() {
    LOG_INFO "Start loading data!"
    SSH_CMD "lsblk > /tmp/diskfile" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_SCP "${NODE2_USER}@${NODE2_IPV4}:/tmp/diskfile" ./diskfile "${NODE2_PASSWORD}"
    disk_list=($(awk '{print$1" "$6}' diskfile | grep disk | awk '{print$1}'))
    for disk in "${disk_list[@]}"; do
        awk '{print$1}' diskfile | grep -w ${disk} -A 1 | grep -E "└─|├─" >/dev/nul || awk '{print$1" "$6" "$7}' diskfile | grep / | awk '{print$1" "$2}' | grep -w ${disk} | awk '{print$2}' | grep disk >/dev/nul
        if [ $? -eq 0 ]; then
            disk_list=(${disk_list[@]/${disk}/})
        fi
    done
    [ ${#disk_list[@]} -ge 1 ] || exit 1
    remote_disk=$(shuf -e "${disk_list[@]}" | head -n 1)
    LOG_INFO "Loading data is complete!"
}
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    SSH_CMD "yum install -y vsftpd;systemctl start vsftpd;
    cp /etc/vsftpd/ftpusers /etc/vsftpd/ftpusers.bak;sed -i /root/d /etc/vsftpd/ftpusers;echo \\\"#root\\\" >> /etc/vsftpd/ftpusers;
    cp /etc/vsftpd/user_list /etc/vsftpd/user_list.bak;sed -i /root/d /etc/vsftpd/user_list;echo \\\"#root\\\" >> /etc/vsftpd/user_list;
    systemctl restart vsftpd" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    DNF_INSTALL ftp
    setsebool -P ftpd_full_access=on
    SSH_CMD "setsebool -P ftpd_full_access=on" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    SSH_CMD "mkfs.ext4 -F /dev/${remote_disk}" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "mount /dev/${remote_disk} /var/ftp/pub/;chmod -R 777 /var/ftp/pub" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "dd if=/dev/zero of=/var/ftp/pub/test bs=1k" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    mkdir -p /root/ftptest/
    cd /root/ftptest/ || exit 1
    echo "hello world!" >upload_file1.txt
    ftp -n ${NODE2_IPV4} >log <<EOF
user root ${NODE2_PASSWORD}
cd /var/ftp/pub
put upload_file1.txt
bye
EOF
    CHECK_RESULT $?
    SSH_CMD "find /var/ftp/pub/upload_file1.txt" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    SSH_CMD "cat /var/ftp/pub/upload_file1.txt | grep \\\"hello world\\\"" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $? 1
    SSH_CMD "rm -rf /var/ftp/pub/*" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    ftp -n ${NODE2_IPV4} >log <<EOF
user root ${NODE2_PASSWORD}
cd /var/ftp/pub
put upload_file1.txt
bye
EOF
    CHECK_RESULT $?
    SSH_CMD "find /var/ftp/pub/upload_file1.txt" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    SSH_CMD "cat /var/ftp/pub/upload_file1.txt | grep \\\"hello world\\\"" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    CHECK_RESULT $?
    cd - || exit 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    SSH_CMD "
    umount /var/ftp/pub/
    mv /etc/vsftpd/ftpusers.bak /etc/vsftpd/ftpusers
    mv /etc/vsftpd/user_list.bak /etc/vsftpd/user_list
    rm -rf /var/ftp/pub/upload_file1.txt
    yum remove -y vsftpd" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    rm -rf /root/ftptest/ /tmp/diskfile ./diskfile
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
