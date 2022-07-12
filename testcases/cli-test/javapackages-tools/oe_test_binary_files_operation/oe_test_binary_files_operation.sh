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
# @Date      :   2020/10/26
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of check-binary-files,clean-binary-files,create-jar-links and diff-jars command
# ############################################

source "../common/common_javapackages-tools.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL tar
    deploy_env
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mkdir hello
    CHECK_RESULT $?
    cp /usr/share/java/*.jar hello/
    echo 'public class Hello{
    public static void main(String[] args){
        System.out.println("Hello java!");
    }
}' >>hello/Hello.java
    tar cvzf hello.tar.gz hello
    test -f hello.tar.gz
    CHECK_RESULT $?
    touch exclusion
    clean-binary-files -e exclusion -l -a hello.tar.gz >instructions
    CHECK_RESULT $?
    grep "remove hello/" instructions
    CHECK_RESULT $?
    test -f hello-clean.tar.gz
    CHECK_RESULT $?
    check-binary-files -f instructions -a hello-clean.tar.gz | grep "ERROR"
    CHECK_RESULT $?
    rm -rf hello-clean.tar.gz
    clean-binary-files -f instructions -n -a hello.tar.gz | grep 'rm -f "hello/'
    CHECK_RESULT $?
    test -f hello-clean.tar.gz
    CHECK_RESULT $?
    check-binary-files -f instructions -a hello-clean.tar.gz | grep "ERROR"
    CHECK_RESULT $? 1
    test -f hello-clean-clean.tar.gz
    CHECK_RESULT $?
    mv hello hello_old
    tar zxvf hello-clean-clean.tar.gz
    test -d hello
    CHECK_RESULT $?
    create-jar-links -f instructions | grep "build-jar-repository -s"
    CHECK_RESULT $?
    ls -l hello | grep "].jar -> /usr/share/java/"
    CHECK_RESULT $?
    create-jar-links -f instructions -a hello-clean-clean.tar.gz | grep "build-jar-repository -s"
    CHECK_RESULT $?
    test -f hello-clean-clean-clean.tar.gz
    CHECK_RESULT $?
    mv hello hello_old2
    tar zxvf hello-clean-clean-clean.tar.gz
    ls -l hello | grep "].jar -> /usr/share/java/"
    CHECK_RESULT $?
    create-jar-links -f instructions -p
    CHECK_RESULT $?
    ls -l hello | grep -E "].jar -> /usr/share/java/|.jar -> /usr/share/java/"
    CHECK_RESULT $?
    rm -rf hello-clean-clean-clean.tar.gz
    create-jar-links -f instructions -p -a hello-clean-clean.tar.gz
    CHECK_RESULT $?
    test -f hello-clean-clean-clean.tar.gz
    CHECK_RESULT $?
    diff-jars /usr/share/java/easymock.jar /usr/share/java/junit.jar | grep "+org/"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
