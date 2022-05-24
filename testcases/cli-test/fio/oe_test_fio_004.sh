#!/usr/bin/bash

# Copyright (c) 2020 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   duanxuemin
# @Contact   :   duanxuemin_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   fio command test
# ############################################
source ./common/disk_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    check_free_disk
    DNF_INSTALL fio
    echo "dsafdsfdddddddddddddddddddddddddddddddddddddddddd" >test.txt
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    fio-genzipf -t normal | grep "Generating Normal distribution with 0.000000"
    CHECK_RESULT $? 0 0 "failed to test fio-genzipf-t option"
    fio-genzipf -i zipf theta | grep "Total"
    CHECK_RESULT $? 0 0 "failed to test fio-genzipf-i option"
    fio-genzipf -i zipf theta -o 2 | grep "Rows"
    CHECK_RESULT $? 0 0 "fio-genzipf -o option failed"
    fio-genzipf -i zipf theta -o 2 -c | grep 1
    CHECK_RESULT $? 0 0 "fio-genzipf -i zipf theta option failed"
    fio-genzipf -g 2 | grep "Generating Zipf distribution"
    CHECK_RESULT $? 0 0 "fio-genzipf -g 2 option failed"
    fio-genzipf -p 2 | grep "hits satisfied"
    CHECK_RESULT $? 0 0 "fio-genzipf -p option failed"
    fio-genzipf -b 40000 | grep "Generating Zipf distribution with"
    CHECK_RESULT $? 0 0 "fio-genzipf -b option failed"
    fio-verify-state test.txt | grep "Version"
    CHECK_RESULT $? 0 0 "fio-verify-state option failed"
    fio-dedupe -t 3 /dev/${local_disk} | grep "Will check </dev/${local_disk}>"
    CHECK_RESULT $? 0 0 "check disk failed"
    fio-dedupe -d 3 /dev/${local_disk} | grep "Will check </dev/${local_disk}>"
    CHECK_RESULT $? 0 0 "check disk failed"
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    rm -rf test.txt 
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
