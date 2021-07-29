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
# @Date      :   2020/10/16
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of php-cgi and phpize command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "php-cli php-devel"
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    php-cgi --help | grep "\-"
    CHECK_RESULT $?
    php-cgi -v | grep "PHP"
    CHECK_RESULT $?
    expect <<EOF
        spawn php-cgi -a
        expect "" {send "\04"}
        expect eof
EOF
    php-cgi -c ./ ../common/my_script.php | grep -E "X-Powered-By: PHP/7.2.10|Content-type: text/html; charset=UTF-8|PHP test"
    CHECK_RESULT $?
    php-cgi -n -f ../common/my_script.php | grep "PHP test"
    CHECK_RESULT $?
    php-cgi -e ../common/my_script.php | grep -E "X-Powered-By: PHP/7.2.10|Content-type: text/html; charset=UTF-8|PHP test"
    CHECK_RESULT $?
    php-cgi -i | grep -E "<tr>|class|<table>"
    CHECK_RESULT $?
    php-cgi -l ../common/my_script.php | grep "No syntax errors detected in.*"
    CHECK_RESULT $?
    php-cgi -l ../common/test.php | grep "No syntax errors detected in.*"
    CHECK_RESULT $?
    php-cgi -m | grep -E "\[PHP Modules\]|\[Zend Modules\]"
    CHECK_RESULT $?
    php-cgi -m | grep -E "\[PHP Modules\]|\[Zend Modules\]"
    CHECK_RESULT $?
    php-cgi -q ../common/my_script.php
    CHECK_RESULT $?
    php-cgi -s ../common/my_script.php
    CHECK_RESULT $?
    php-cgi -w ../common/my_script.php
    CHECK_RESULT $?
    php-cgi -T 3 ../common/my_script.php | grep -E "PHP test|Elapsed time:"
    CHECK_RESULT $?

    phpize --help | grep "Usage:"
    CHECK_RESULT $?
    phpize --version | grep -E "Version|No"
    CHECK_RESULT $?
    phpize --clean | grep "Cannot find config.m4"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
