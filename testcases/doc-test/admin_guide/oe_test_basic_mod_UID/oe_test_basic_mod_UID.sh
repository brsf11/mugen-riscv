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
# @Contact   :   xcl_job@163.com
# @Date      :   2020.04-09
# @License   :   Mulan PSL v2
# @Desc      :   Modify UID
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start executing testcase!"
    grep -w testuser /etc/passwd && userdel -r testuser
    grep -w testuser /etc/group && groupdel -r testuser
    useradd testuser
    passwd testuser <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF

    CHECK_RESULT $?
    grep testuser /etc/passwd
    CHECK_RESULT $?

    id=$(id testuser | cut -d " " -f 1 | tr -cd "[0-9]")
    CHECK_RESULT $?
    usermod -u ${id}3 testuser
    CHECK_RESULT $?
    id testuser | grep ${id}3
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -r testuser
    LOG_INFO "Finish environment cleanup."
}

main $@
