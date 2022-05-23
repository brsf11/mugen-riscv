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
    test -f test.txt || touch test.txt
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    fio-genzipf -t normal | grep "Generating Normal distribution"
    CHECK_RESULT $? 0 0 "fio-genzipf -t option failed"
    fio-genzipf -i zipf theta | grep "Generating Zipf distribution"
    CHECK_RESULT $? 0 0 "Generating Zipf distribution option failed"
    fio-genzipf -i zipf theta -o 2 | grep "block_size"
    CHECK_RESULT $? 0 0 "fio-genzipf -i zipf theta -o option failed"
    fio-genzipf -i zipf theta -o 2 -c
    CHECK_RESULT $? 0 0 "fio-genzipf -i zipf theta -o 2 -c failed "
    fio-genzipf -g 2 | grep "2 GiB size and 4096 block_size"
    CHECK_RESULT $? 0 0 "fio-genzipf -g option failed"
    fio-genzipf -p 2 | grep "Total"
    CHECK_RESULT $? 0 0 "fio-genzipf -p option failed"
    fio-genzipf -b 40000 | grep "Generating Zipf distribution"
    CHECK_RESULT $? 0 0 "fio-genzipf -b option failed"
    fio-verify-state test.txt | grep "Version"
    CHECK_RESULT $? 0 0 " fio-verify-state option failed"
    fio-dedupe -t 3 /dev/${local_disk} | grep "Will check </dev/${local_disk}>"
    CHECK_RESULT $? 0 0 "fio-dedupe option failed"
    fio-dedupe -d 3 /dev/${local_disk} | grep "Will check </dev/${local_disk}>"
    CHECK_RESULT $? 0 0 "fio-dedupe option failed"
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    rm -rf test.txt  
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
