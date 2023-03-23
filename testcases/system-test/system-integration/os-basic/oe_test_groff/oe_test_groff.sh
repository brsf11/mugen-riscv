#!/usr/bin/bash

# Copyright (c) 2023. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   wulei
# @Contact   :   wulei@uniontech.com
# @Date      :   2023-02-07
# @License   :   Mulan PSL v2
# @Desc      :   Groff document format
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    Tascii_result=$(echo "Hello, world!" | groff -Tascii |wc -l)
    CHECK_RESULT $Tascii_result 66 0 "groff Tascii fail"
    echo "Hello, world!" | groff -Thtml | grep '<html>'
    CHECK_RESULT $? 0 0 "groff fail"
    Tutf8_result=$(echo "Hello, world!" | groff -Tascii |wc -l)
    CHECK_RESULT $Tutf8_result 66 0 "groff Tutf8 fail"
    LOG_INFO "End to run test."
}

main $@