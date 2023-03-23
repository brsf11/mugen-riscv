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
# @Author    :   huzheyuan
# @Contact   :   huzheyuan@uniontech.com
# @Date      :   2022.12.06
# @License   :   Mulan PSL v2
# @Desc      :   File system common command builtin
# ############################################
source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start testing..."
    cd /etc/init.d
    pwd -L | grep /etc/init.d
    CHECK_RESULT $? 0 0 "Command executed fail"
    pwd -P | grep /etc/rc.d/init.d
    CHECK_RESULT $? 0 0 "Command executed fail"
    LOG_INFO "Finish test!"
}

main $@




