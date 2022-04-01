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
# @Desc      :   Common Samba command line utilities-smbpasswd
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL samba
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    useradd testsamba
    (
        echo testpasswd
        echo testpasswd
    ) | smbpasswd -a testsamba -s
    CHECK_RESULT $?
    expect -c "
        log_file testlog
		spawn smbpasswd testsamba
		expect \"*assword*\" {send \"${NODE1_PASSWORD}\\r\";
		expect \"*assword*\" {send \"${NODE1_PASSWORD}\\r\"}}
		expect eof
	"
    grep -iE "error|fail" testlog
    CHECK_RESULT $? 1
    smbpasswd -d testsamba
    CHECK_RESULT $?
    smbpasswd -e testsamba
    CHECK_RESULT $?
    smbpasswd -x testsamba
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    userdel -rf testsamba
    rm -rf testlog
    LOG_INFO "Finish environment cleanup."
}

main $@
