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
# @Desc      :   User password modification_current user
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    useradd test26
    passwd test26 <<EOF
${NODE1_PASSWORD}
${NODE1_PASSWORD}
EOF
    LOG_INFO "Environmental preparation is over."
}
function run_test() {
    LOG_INFO "Start executing testcase!"
    echo test >/home/tmp
    su test26 -c "mkdir -p /home/tmp26"
    CHECK_RESULT $?
    expect -c"
        spawn scp /home/tmp test26@${NODE1_IPV4}:/home/tmp6
        expect {
                \"*)?\"  {
                        send \"yes\r\"
                        exp_continue
                }
                \"*assword:*\"  {
                        send \"${NODE1_PASSWORD}\r\"
                        exp_continue
                }
}
"
    su test26 -c "ls /home/tmp26/tmp"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    userdel -r tmp26
    rm -rf /home/tmp
    LOG_INFO "Finish environment cleanup."
}

main $@
