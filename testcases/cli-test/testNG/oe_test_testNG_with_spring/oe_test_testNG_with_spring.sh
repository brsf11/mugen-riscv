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
#@Author        :   wangjingfeng
#@Contact       :   1136232498@qq.com
#@Date          :   2020/4/29
#@License       :   Mulan PSL v2
#@Desc          :   testNG integration spring
####################################
source ../common/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    pre_env
    DNF_INSTALL "springframework springframework-beans springframework-context springframework-expression apache-commons-logging"
    springcore_jar=$(rpm -ql springframework | grep spring-core.jar)
    springbeans_jar=$(rpm -ql springframework-beans | grep spring-beans.jar)
    springcontext_jar=$(rpm -ql springframework-context | grep spring-context.jar)
    springexpression_jar=$(rpm -ql springframework-expression | grep spring-expression.jar)
    springtest_jar=$(rpm -ql springframework-test | grep spring-test.jar)
    commonslogging_jar=$(rpm -ql apache-commons-logging | grep commons-logging.jar)
    export CLASSPATH=${CLASSPATH}:${springcore_jar}:${springbeans_jar}:${springcontext_jar}:${springexpression_jar}:${springtest_jar}:${commonslogging_jar}

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    javac User.java
    CHECK_RESULT $? 0 0 "User.java source code compilation failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    clean_env

    LOG_INFO "End to restore the test environment."
}

main "$@"
