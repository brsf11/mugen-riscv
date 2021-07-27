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
#@Author    	:   yanglijin/limeiting
#@Contact   	:   1050472997@qq.com/244349477@qq.com
#@Date      	:   2021-02-20
#@License   	:   Mulan PSL v2
#@Desc      	:   Pkgship items normal function test
#####################################

source ../../common_lib/pkgship_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."

    mv ${SYS_CONF_PATH}/package.ini ${SYS_CONF_PATH}/package.ini.bak
    cp -p package.ini ${SYS_CONF_PATH}/package.ini
    chown pkgshipuser:pkgshipuser ${SYS_CONF_PATH}/package.ini
    mkdir -p /文件夹1/Test2/文件夹3/文件夹4/Test5/文件夹6/pkgship7/文件夹8/pkgship9/文件夹10/pkgship11
    chmod -R 777 /文件夹1
    cp -p conf.yaml /文件夹1/Test2/文件夹3/文件夹4/Test5/文件夹6/pkgship7/文件夹8/pkgship9/文件夹10/pkgship11/Conf@*配置.yaml
    chown pkgshipuser:pkgshipuser /文件夹1/Test2/文件夹3/文件夹4/Test5/文件夹6/pkgship7/文件夹8/pkgship9/文件夹10/pkgship11/Conf@*配置.yaml

    LOG_INFO "Finish to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
 
    # Start server to check 
    ACT_SERVICE

    # Init by absulte path
    pkgship init -filepath /文件夹1/Test2/文件夹3/文件夹4/Test5/文件夹6/pkgship7/文件夹8/pkgship9/文件夹10/pkgship11/Conf@*配置.yaml >/dev/null
    SLEEP_WAIT 5
    pkgship dbs | grep "openeuler-test-init"
    CHECK_RESULT $? 0 0 "The db openeuler-test-init doesn't create on ES."

    ls -l /文件夹1/hello2/conf3/LOG4/文件夹5/文件夹6/pkgship7/文件夹8/pkgship9/文件夹10/log_info.log
    CHECK_RESULT $? 0 0 "Check log failed."

    ls -l /var/log/pkgship-operation/日志HellO@10.log
    CHECK_RESULT $? 0 0 "Check uwsgi log failed."

    # Close server
    ACT_SERVICE stop

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    rm -rf /文件夹1 /var/log/pkgship-operation/日志HellO@10.log ${SYS_CONF_PATH}/package.ini
    mv ${SYS_CONF_PATH}/package.ini.bak ${SYS_CONF_PATH}/package.ini
    REVERT_ENV
    
    LOG_INFO "End to restore the test environment."
}

main $@
