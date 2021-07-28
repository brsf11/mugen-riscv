#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/05/20
# @License   :   Mulan PSL v2
# @Desc      :   Junit4+maven integration testing
# ############################################

source "../common/common_junit.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    DNF_INSTALL maven
    cp /etc/profile /etc/profile-bak
    echo -e "export MAVEN_HOME=/usr/share/maven\nexport PATH=\$PATH:\$MAVEN_HOME" >>/etc/profile
    source /etc/profile
    mkdir libs
    cp -r "$(rpm -ql junit | grep junit.jar)" "$(rpm -ql hamcrest | grep core.jar)" libs
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mvn test >log
    grep "Tests run: 2, Failures: 0, Errors: 0, Skipped: 0"$'\n'"BUILD SUCCESS" log
    CHECK_RESULT $?
    mvn -Dtest=TestApp2 test >log
    grep "Tests run: 1, Failures: 0, Errors: 0, Skipped: 0"$'\n'"BUILD SUCCESS" log
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    mv /etc/profile-bak /etc/profile -f
    source /etc/profile
    rm -rf $(ls | grep -vE ".xml|main|.sh|test") /root/.m2
    LOG_INFO "Finish restoring the test environment."
}

main $@
