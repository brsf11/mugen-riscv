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
#@Date          :   2020-10-19
#@License       :   Mulan PSL v2
#@Desc          :   pcp testing(pmpython,mkaf,pcp-python)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    archive_data=$(pcp -h "$host_name" | grep 'primary logger:' | awk -F: '{print $NF}')
    cat >my.py <<EOF
print ("There are four numbers:1,2,3,4 How many different three digit numbers can be formed without repeating numbers?")
for i in range(1,5):
    for j in range(1,5):
        for k in range(1,5):
            if (i != j) and (i != k) and (j != k):
                print (i,j,k)
EOF
    python3_version=$(python3 --version)
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pmpython --help 2>&1 | grep 'usage'
    CHECK_RESULT $?
    pmpython --version 2>&1 | grep "$python3_version"
    CHECK_RESULT $?
    pmpython my.py | grep 'without'
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/mkaf | grep 'Usage'
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/mkaf ${archive_data}.index | grep 'PCPFolio'
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pcp-python --help 2>&1 | grep 'usage'
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pcp-python --version 2>&1 | grep "$python3_version"
    CHECK_RESULT $?
    /usr/libexec/pcp/bin/pcp-python my.py | grep 'without'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -f my.py
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
