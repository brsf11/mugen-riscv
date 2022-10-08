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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/07/13
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of cifs client
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "cifs-utils samba"
    cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
    echo "[share]
        comment = share folder
        path = /tmp
        force group = nogroup
        create mask = 0777
        directory mask = 0777
" >>/etc/samba/smb.conf
    systemctl start smb
    useradd smbtest
    smbpasswd -a smbtest <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    which mount.cifs | grep "/usr/sbin/mount.cifs"
    CHECK_RESULT $? 0 0 "Cifs service deployment failed"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop smb
    userdel -rf smbtest
    mv /etc/samba/smb.conf.bak /etc/samba/smb.conf
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
