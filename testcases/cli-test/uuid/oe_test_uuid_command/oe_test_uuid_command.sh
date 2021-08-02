#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
# ##################################
# @Author    :   zengcongwei
# @Contact   :   735811396@qq.com
# @Date      :   2020/10/09
# @License   :   Mulan PSL v2
# @Desc      :   Test uuid command
# ##################################
source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "uuid"
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    uuid | grep "-"
    CHECK_RESULT $? 0 0
    uuid -v4 | grep "-"
    CHECK_RESULT $? 0 0
    uuid -v3 ns:URL http://www.baidu.com | grep "-"
    CHECK_RESULT $? 0 0
    uuid -v5 ns:URL http://www.baidu.com | grep "-"
    CHECK_RESULT $? 0 0
    mac_id=$(uuid | awk -F "-" '{print $5}')
    uuid -m | grep ${mac_id}
    CHECK_RESULT $? 1 0
    uuid -n 10 | wc -l | grep 10
    CHECK_RESULT $? 0 0
    uuid -n 10 -1
    CHECK_RESULT $? 0 0
    uuid -F BIN
    CHECK_RESULT $? 0 0
    uuid -F STR
    CHECK_RESULT $? 0 0
    uuid -F SIV
    CHECK_RESULT $? 0 0
    uuid -F SIV | grep "-"
    CHECK_RESULT $? 1 0
    uuid -o uuid_file
    cat uuid_file | grep "-"
    CHECK_RESULT $? 0 0
    id=$(cat uuid_file)
    uuid -d ${id}
    CHECK_RESULT $? 0 0
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
