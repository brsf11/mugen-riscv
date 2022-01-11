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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020.04-09
# @License   :   Mulan PSL v2
# @Desc      :   Delete User test
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function config_params() {
    user="testuser"
    LOG_INFO "Loading data is complete!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    groupdel ${user}    
    egrep "^${user}" /etc/passwd >&/dev/null
    if [ $? -ne 0 ]; then
        useradd ${user}
        userdel -r ${user}
    else
        userdel -r ${user}
    fi
    test -f /home/${user}
    CHECK_RESULT $? 1

    grep ${user} /etc/passwd
    CHECK_RESULT $? 1
    LOG_INFO "End of testcase execution!"
}

main $@
