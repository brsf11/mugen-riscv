#!/usr/bin/bash

# Copyright (c) 2023 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   pengrui
# @Contact   :   pengrui@uniontech.com
# @Date      :   2023.2.7
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-tr
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test(){
    LOG_INFO "Start environment preparation."
    cat > /tmp/test_tr  <<EOF
aabbccddeeff
gghh
123456
mmnn
EOF
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    tr --v
    CHECK_RESULT $? 0 0 "Version is error"
    cd /tmp&&tr -d "gghh" <test_tr> tr.result
    grep gghh /tmp/tr.result
    CHECK_RESULT $? 1 0 "delete testfile fail"    
    tr -t "[123456]" "[oopptt]" <test_tr> tr.result
    grep oopp /tmp/tr.result
    CHECK_RESULT $? 0 0 "cover testfile fail"
    tr -s "[abcdef]" <test_tr> tr.result
    grep abc /tmp/tr.result
    CHECK_RESULT $? 0 0 "duplicate removal error"   
    tr -c "0-9" "*" <test_tr> tr.result
    grep 123456 /tmp/tr.result
    CHECK_RESULT $? 0 0 "replace testfile fail"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /tmp/test_tr
    rm -rf /tmp/tr.result
    LOG_INFO "Finish environment cleanup!"
}

main $@