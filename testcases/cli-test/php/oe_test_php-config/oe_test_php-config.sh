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
# @Date      :   2020/10/20
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of php-config command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL php-devel
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    php-config --help | grep "Usage:"
    CHECK_RESULT $?
    php-config --version | grep ".*"
    CHECK_RESULT $?
    php-config --vernum | grep "0"
    CHECK_RESULT $?
    php-config --prefix | grep "/usr"
    CHECK_RESULT $?
    php-config --includes | grep "/usr"
    CHECK_RESULT $?
    php-config --ldflags
    CHECK_RESULT $?
    php-config --libs | grep "-"
    CHECK_RESULT $?
    php-config --extension-dir | grep "/usr/lib64/php/modules"
    CHECK_RESULT $?
    php-config --include-dir | grep "/usr/include/php"
    CHECK_RESULT $?
    php-config --php-binary | grep "/usr/bin/php"
    CHECK_RESULT $?
    php-config --php-sapis|grep "apache2handler .* fpm .*"
    CHECK_RESULT $?
    php-config --configure-options | grep "\--"
    CHECK_RESULT $?
    php-config --man-dir | grep "/usr/share/man"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
