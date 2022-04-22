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
# @Desc      :   tomcat command test
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL tomcat 
    systemctl start tomcat
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    systemctl status tomcat | grep "running"
    CHECK_RESULT $?
    tomcat-tool-wrapper -server org.apache.catalina.realm.RealmBase md5 | grep "md5"
    CHECK_RESULT $?
    tomcat-digest -a SHA-256 Foo | grep "Foo"
    CHECK_RESULT $?
    tomcat-digest -e SHA-256 Foo | grep "Foo"
    CHECK_RESULT $?
    tomcat-digest -h  Foo | grep "Foo"
    CHECK_RESULT $?
    tomcat-digest -k  Foo | grep "Foo"
    CHECK_RESULT $?
    tomcat-digest -i  Foo
    CHECK_RESULT $?
    tomcat-digest -s Foo
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    systemctl stop tomcat
    DNF_REMOVE 
    LOG_INFO "Finish environment cleanup."
}

main $@
