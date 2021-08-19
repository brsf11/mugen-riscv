#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-10-15
#@License       :   Mulan PSL v2
#@Desc          :   pcp testing(pmjson)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    cat >my.js <<EOF
{
    "employees": [
        { "firstName":"Bill" , "lastName":"Gates" },
        { "firstName":"George" , "lastName":"Bush" },
        { "firstName":"Thomas" , "lastName":"Carter" }
    ]
}
EOF
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pmjson --version 2>&1 | grep "$pcp_version"
    CHECK_RESULT $?
    pmjson -i my.js | grep 'employees'
    CHECK_RESULT $?
    pmjson -i my.js -o t.txt
    CHECK_RESULT $?
    grep 'firstName' t.txt
    CHECK_RESULT $?
    pmjson -mi my.js | grep 'lastName'
    CHECK_RESULT $?
    pmjson -pi my.js | grep 'Bill'
    CHECK_RESULT $?
    pmjson -qi my.js
    CHECK_RESULT $?
    pmjson -yi my.js | grep 'Gates'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -f my.js t.txt
    LOG_INFO "End to restore the test environment."
}

main "$@"
