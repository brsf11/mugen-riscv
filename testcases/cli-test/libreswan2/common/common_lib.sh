#!/usr/bin/bash
# Copyright (c) [2020] Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author        :   meitingli
# @Contact       :   244349477@qq.com
# @Date          :   2021-08-10
# @License       :   Mulan PSL v2
# @Desc          :   Public function
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function SET_CONF() {
    DNF_INSTALL libreswan
    DNF_INSTALL libreswan 2
    cp ./common/test-vm.secrets /etc/ipsec.d/test-vm.secrets
    sed -i "s/left=left/left=${NODE1_IPV4}/g" /etc/ipsec.d/test-vm.secrets
    sed -i "s/right=right/right=${NODE2_IPV4}/g" /etc/ipsec.d/test-vm.secrets
    sed -i "s/leftid=testA/leftid=${NODE1_IPV4}/g" /etc/ipsec.d/test-vm.secrets
    sed -i "s/rightid=testB/rightid=${NODE2_IPV4}/g" /etc/ipsec.d/test-vm.secrets

    SSH_SCP ./common/test-vm.secrets ${NODE2_USER}@${NODE2_IPV4}:/etc/ipsec.d ${NODE2_PASSWORD}
    SSH_CMD "sed -i 's/left=left/left=${NODE2_IPV4}/g' /etc/ipsec.d/test-vm.secrets
            sed -i 's/right=right/right=${NODE1_IPV4}/g' /etc/ipsec.d/test-vm.secrets
            sed -i 's/leftid=testA/leftid=${NODE2_IPV4}/g' /etc/ipsec.d/test-vm.secrets
            sed -i 's/rightid=testB/rightid=${NODE1_IPV4}/g' /etc/ipsec.d/test-vm.secrets
            systemctl stop firewalld
            ipsec restart" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    ipsec restart
}

function ADD_CONN() {
    ipsec auto --config /etc/ipsec.d/test-vm.secrets --add test-vm-test >/dev/null
    SSH_CMD "ipsec auto --config /etc/ipsec.d/test-vm.secrets --add test-vm-test" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    ipsec auto --up test-vm-test >/dev/null
    ipsec auto --up test-vm-test >/dev/null
}

function REVERT_CONF() {
    rm -f /etc/ipsec.d/test-vm.secrets
    SSH_CMD "systemctl restart firewalld
            rm -f /etc/ipsec.d/test-vm.secrets" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    DNF_REMOVE
}

