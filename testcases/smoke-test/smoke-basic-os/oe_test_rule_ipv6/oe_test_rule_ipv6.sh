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
# @Desc      :   Test ip add ipv6 rule
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    ip -6 rule add from 2002::2 pref 1 table 100
    CHECK_RESULT $? 0 0 "Failed to add route"
    ip -6 rule list | grep "2002::2"
    CHECK_RESULT $? 0 0 "Failed to show route"
    ip -6 rule del from 2002::2 pref 1 table 100
    CHECK_RESULT $? 0 0 "Failed to delete route"
    ip -6 rule list | grep "2002::2"
    CHECK_RESULT $? 0 1 "Succeed to show route"
    LOG_INFO "End to run test."
}

main "$@"
