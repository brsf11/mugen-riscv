#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   wangpeng
# @Contact   :   wangpengb@uniontech.com
# @Date      :   2022.3.16
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-which
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start testing..."
    rpm -qa | grep which
    CHECK_RESULT $? 0 0 "which not install"
    which -v | grep -E "GNU which v[0-9]\.[0-9]+"
    CHECK_RESULT $? 0 0 "check version failed"
    which bash | grep "/usr/bin/bash"
    CHECK_RESULT $? 0 0 "which function failed"
    LOG_INFO "Finish test!"
}

main $@
