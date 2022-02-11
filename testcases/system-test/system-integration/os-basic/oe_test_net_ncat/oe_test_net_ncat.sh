#!/usr/bin/bash

#Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-4-30
# @License   :   Mulan PSL v2
# @Desc      :   Ncat communication test
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL nmap
    iptables -F
    SSH_CMD "
            yum install -y nmap iptables;
            iptables -F;
            systemctl stop firewalld" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    echo "Start executing testcase."
    SSH_CMD "ncat -l 8080 >> ~/ncat_log 2>&1 &" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    echo -e "123\\n456\\n004\\n" | ncat "${NODE2_IPV4}" 8080
    CHECK_RESULT $?
    SSH_SCP "root@${NODE2_IPV4}:/root/ncat_log" . "${NODE2_PASSWORD}"
    CHECK_RESULT "$(grep -icE '123|456|004' ncat_log)" 3
    echo "End of testcase execution."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf ncat_log
    DNF_REMOVE
    SSH_CMD "yum remove -y nmap; rm -rf ~/ncat_log" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    LOG_INFO "End to restore the test environment."
}

main "$@"
