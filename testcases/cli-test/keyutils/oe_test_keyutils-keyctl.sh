#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   yangchenguang
# @Contact   :   yangchenguang@uniontech.com
# @Date      :   2022/08/02
# @License   :   Mulan PSL v2
# @Desc      :   Test keyutils api
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "keyutils"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    keyctl --version | grep "keyctl from keyutils"
    CHECK_RESULT $? 0 0 "version error"
    keyctl supports | grep "have_capabilities"
    CHECK_RESULT $? 0 0 "support info error"
    keyctl add user mykey:hello stuff @u
    keyctl list @u | grep "user: mykey:hello"
    CHECK_RESULT $? 0 0 "add user failed"
    keyctl search @u user mykey:hello
    CHECK_RESULT $? 0 0 "search user failed"
    key_id=$(keyctl request user mykey:hello)
    echo -n zebra | keyctl pupdate ${key_id}
    keyctl pipe ${key_id} | grep "zebra"
    CHECK_RESULT $? 0 0 "keyctl update failed"
    keyctl revoke ${key_id}
    CHECK_RESULT $? 0 0 "keyctl revoke failed"
    keyctl clear @u
    keyctl list @u | grep "user: mykey:hello"
    CHECK_RESULT $? 0 1 "keyctl clear failed"
    LOG_INFO "Finish testing!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
