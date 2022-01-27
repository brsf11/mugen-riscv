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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020.4-9
# @License   :   Mulan PSL v2
# @Desc      :   Enable source, disable source
# #############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start executing testcase."
    reponame=$(dnf repolist | grep "repo id" -A 1 | grep -v "repo id" | awk '{print$1}')
    dnf config-manager --set-disable "${reponame}"
    CHECK_RESULT $?
    CHECK_RESULT $(grep ${reponame} -A 4 /etc/yum.repos.d/openEuler.repo | grep "enabled=" | awk -F '=' '{print$2}') 0
    dnf config-manager --set-enable "${reponame}"
    CHECK_RESULT $?
    CHECK_RESULT $(grep ${reponame} -A 4 /etc/yum.repos.d/openEuler.repo | grep "enabled=" | awk -F '=' '{print$2}') 0
    LOG_INFO "End of testcase execution."
}

main $@
