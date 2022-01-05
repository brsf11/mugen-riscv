#!/usr/bin/bash
  
# Copyright (c) 2021 Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2021-07-29
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-df
# ############################################
source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start testing..."
    df | grep '/boot/efi'
    CHECK_RESULT $? 0 0 "df display error"
    df | grep 'G'
    CHECK_RESULT $? 1 0 "df default display error"
    df -h | grep -E 'G|M|K'
    CHECK_RESULT $? 0 0 "df -h didn't find G|M|K"
    df --help
    CHECK_RESULT $? 0 0 "df --help error"
    LOG_INFO "Finish test!"
}

main $@

