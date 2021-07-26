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
# @Date      :   2020/05/28
# @License   :   Mulan PSL v2
# @Desc      :   Set password complexity
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    cp /etc/pam.d/system-auth /etc/pam.d/system-auth-bak
    grep "^test:" /etc/passwd && userdel -rf test
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    sed -i 's/password    requisite     pam_pwquality.so try_first_pass local_users_only/password    requisite     pam_pwquality.so minlen=8 minclass=3 enforce_for_root try_first_pass local_users_only retry=3 dcredit=0 ucredit=0 lcredit=0 ocredit=0\npassword    required      pam_pwhistory.so use_authtok remember=5 enforce_for_root/g' /etc/pam.d/system-auth
    useradd test
    passwd test <<EOF
test1
test1
EOF
    CHECK_RESULT $? 0 1 "check passwd(test1) failed"
    passwd test <<EOF
openeuler12
openeuler12
EOF
    CHECK_RESULT $? 0 1 "check passwd(openeuler12) failed"
    passwd test <<EOF
Adminstrator12#$
Adminstrator12#$
EOF
    CHECK_RESULT $? 0 0 "check passwd(Adminstrator12#$) failed"
    passwd test <<EOF
Adminstrator12#$
Adminstrator12#$
EOF
    CHECK_RESULT $? 0 1 "check passwd(Adminstrator12#$) failed"
    passwd test <<EOF
test1
test1
test1
EOF
    CHECK_RESULT $? 0 1 "check passwd(test1) failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    mv /etc/pam.d/system-auth-bak /etc/pam.d/system-auth -f
    userdel -rf test
    echo >/etc/security/opasswd
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
