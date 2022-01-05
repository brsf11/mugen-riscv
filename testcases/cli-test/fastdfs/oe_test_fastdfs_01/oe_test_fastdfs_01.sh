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
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date          :   2021-10-27 09:00:43
#@License   	:   Mulan PSL v2
#@Desc          :   verification fastdfs's commnd
#####################################
source ../common/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    Pre_Test
    storage_path=${OET_PATH}/testcases/cli-test/fastdfs/oe_test_fastdfs_01
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    fdfs_trackerd ./tracker.conf start
    CHECK_RESULT $? 0 0 "Check fdfs_trackerd start failed."
    netstat -unltp | grep "fdfs_trackerd"
    CHECK_RESULT $? 0 0 "Check fdfs_trackerd start error failed."
    fdfs_storaged $storage_path/storage.conf start
    CHECK_RESULT $? 0 0 "Check fdfs_storaged start failed."
    SLEEP_WAIT 5
    netstat -unltp | grep "storaged"
    CHECK_RESULT $? 0 0 "Check fdfs_storaged start error failed."
    fdfs_append_file --help >./usage.txt
    grep "Usage:" ./usage.txt
    CHECK_RESULT $? 0 0 "Check fdfs_append_file --help failed."
    appender_file=$(fdfs_upload_appender client.conf test1.txt)
    fdfs_append_file client.conf $appender_file test2.txt
    CHECK_RESULT $? 0 0 "Check fdfs_append_file failed."
    fdfs_appender_test --help >./usage1.txt
    grep "Usage:" ./usage1.txt
    CHECK_RESULT $? 0 0 "Check fdfs_appender_test --help failed."
    fdfs_appender_test client.conf test1.txt | grep "successfully"
    CHECK_RESULT $? 0 0 "Check fdfs_appender_test client.conf failed."
    fdfs_appender_test1 --help >./usage2.txt
    grep "Usage:" ./usage2.txt
    CHECK_RESULT $? 0 0 "Check fdfs_appender_test1 --help failed."
    fdfs_appender_test1 client.conf test1.txt | grep "successfully"
    CHECK_RESULT $? 0 0 "Check fdfs_appender_test1 client.conf failed."
    fdfs_trackerd ./tracker.conf stop
    CHECK_RESULT $? 0 0 "Check fdfs_trackerd stop failed."
    fdfs_storaged $storage_path/storage.conf stop
    CHECK_RESULT $? 0 0 "Check fdfs_storaged stop failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf *.txt
    Post_Test
    LOG_INFO "End to restore the test environment."
}
main "$@"
