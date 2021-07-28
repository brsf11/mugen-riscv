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
# @Desc      :   Junit+ant integration testing
# ############################################

source "../common/common_junit.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    DNF_INSTALL ant-junit
    cp /usr/share/java/junit.jar /usr/share/ant/lib/
    cp /etc/profile /etc/profile-bak
    echo -e "export ANT_HOME=/usr/share/ant\nexport PATH=\$PATH:\$ANT_HOME/bin" >>/etc/profile
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ant test >log
    grep "Tests run: 2, Failures: 0, Errors: 0, Skipped: 0"$'\n'"BUILD SUCCESSFUL" log
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /usr/share/ant/lib/junit.jar
    DNF_REMOVE
    mv /etc/profile-bak /etc/profile -f
    source /etc/profile
    rm -rf $(ls | grep -vE ".xml|.java|.sh")
    LOG_INFO "Finish restoring the test environment."
}

main $@
