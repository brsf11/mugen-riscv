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
# @Author    :   fuyh2020
# @Contact   :   fuyahong@uniontech.com
# @Date      :   2020-09-19
# @License   :   Mulan PSL v2
# @Desc      :   Command test lz4
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "lz4"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    cat > lz4_test.txt << EOF
testlz4
EOF
    lz4 -m lz4_test.txt
    CHECK_RESULT $? 0 0 "compress file error"
    ls | grep "lz4_test.txt.lz4"
    CHECK_RESULT $? 0 0 "check compile file error"
    rm -rf lz4_test.txt
    lz4 -dm lz4_test.txt.lz4
    CHECK_RESULT $? 0 0 "decompress file error"
    ls lz4_test.txt
    CHECK_RESULT $? 0 0 "check decompress result error"
    lz4 -h
    CHECK_RESULT $? 0 0 "view help msg error"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf lz4_test.txt*
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
