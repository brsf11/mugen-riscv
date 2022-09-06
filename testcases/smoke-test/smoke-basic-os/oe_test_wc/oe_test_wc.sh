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
# @Author    :   zuohanxu
# @Contact   :   zuohanxu@uniontech.com
# @Date      :   2022.8.10
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-wc
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test(){
    LOG_INFO "Start environment preparation."
    cat > /tmp/test_wc  <<EOF
The first line
The second line
The third line
EOF
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    wc /tmp/test_wc | grep "3" | grep "9" | grep "46"
    CHECK_RESULT $? 0 0 "Return value error"
    wc -l /tmp/test_wc | grep "3"
    CHECK_RESULT $? 0 0 "Error number of rows returned"
    wc -w /tmp/test_wc | grep "9"
    CHECK_RESULT $? 0 0 "Return word error"
    wc -c /tmp/test_wc | grep "46"
    CHECK_RESULT $? 0 0 "Error number of bytes returned"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /tmp/test_wc
    LOG_INFO "Finish environment cleanup!"
}

main $@
