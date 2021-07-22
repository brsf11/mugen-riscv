#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.
# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   Specifies the port of the remote service
# #############################################
source "${OET_PATH}/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."
    SSH_CMD "
    sed -i 's/#Port 22/Port 50000/g' /etc/ssh/sshd_config
    systemctl restart sshd
    systemctl stop firewalld
    " "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    SSH_CMD "
    sed -i 's/Port 50000/#Port 22/g' /etc/ssh/sshd_config
    systemctl restart sshd
    systemctl start firewalld
    " "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}" 15 50000
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

main "$@"
