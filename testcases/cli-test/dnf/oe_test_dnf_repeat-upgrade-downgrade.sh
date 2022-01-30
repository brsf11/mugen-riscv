#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ##################################
# @Author    :   zengcongwei
# @Contact   :   735811396@qq.com
# @Date      :   2020/5/13
# @License   :   Mulan PSL v2
# @Desc      :   repeat upgrade and downgrade packages
# ##################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    if dnf repolist | grep -i update; then
        for ((i = 0; i < 10; i++)); do
            dnf -y upgrade | grep "Upgraded"
            CHECK_RESULT $?
            dnf -y upgrade | grep "Nothing to do"
            CHECK_RESULT $?
            downgrade_list=$(dnf list | grep -i @update | awk '{print $1}')
            dnf -y downgrade ${downgrade_list} | grep "Downgraded"
            CHECK_RESULT $?
            dnf -y downgrade ${downgrade_list} 2>&1 | grep "lowest version already installed, cannot downgrade it"
            CHECK_RESULT $?
        done
    fi
    LOG_INFO "End of the test."
}

main "$@"
