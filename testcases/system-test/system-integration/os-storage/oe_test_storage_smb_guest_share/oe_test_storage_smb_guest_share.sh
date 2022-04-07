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
# @Desc      :   SMB enable guest access sharing
# #############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL samba
    cp -a /etc/samba/smb.conf /etc/samba/smb.conf.bak
    echo -e "\n\n[example]\n\tguest ok = yes" >>/etc/samba/smb.conf
    sed -i "/[global]/a\\\tmap to guest = Bad User" /etc/samba/smb.conf
    sed -i "/[global]/a\\\tguest account = $Guest_user" /etc/samba/smb.conf
    sed -i "/[global]/a\\\tusershare prefix allow list = /data /srv" /etc/samba/smb.conf
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    expect -c "
        set timeout 30
	log_file testlog
        spawn testparm
        expect \"Press enter*\" {send \"\n\\r\"}
        expect eof
    "
    grep -iE "fail|error" testlog
    CHECK_RESULT $? 1
    smbcontrol all reload-config
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -f /etc/samba/smb.conf testlog
    mv /etc/samba/smb.conf.bak /etc/samba/smb.conf
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
