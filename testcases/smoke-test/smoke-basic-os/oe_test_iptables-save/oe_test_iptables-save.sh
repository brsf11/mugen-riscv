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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2022/07/11
# @License   :   Mulan PSL v2
# @Desc      :   Test the basic functions of iptables-save
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    iptables-save | grep -A 200 nat | grep -A 100 mangle | grep -A 80 raw | grep -A 60 security | grep filter
    CHECK_RESULT $? 0 0 "Incomplete display"
    iptables-save -t filter | grep filter
    CHECK_RESULT $? 0 0 "Failed to display filter"
    iptables-save -t filter | grep -E "nat|mangle|raw|security"
    CHECK_RESULT $? 0 1 "Not just filter"
    LOG_INFO "End to run test."
}

main "$@"
