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
# @Desc      :   verify the uasge of php command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "php-cli php-devel"
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    php --help | grep "\-"
    CHECK_RESULT $?
    php --version | grep "PHP"
    CHECK_RESULT $?
    expect <<EOF
        spawn php -a
        expect "php >" {send "quit\r"}
        expect eof
EOF
    php -c ./ ../common/my_script.php | grep "PHP test"
    CHECK_RESULT $?
    php -c ../common/myphp.ini ../common/my_script.php | grep "PHP test"
    CHECK_RESULT $?
    php -n -f ../common/my_script.php | grep "PHP test"
    CHECK_RESULT $?
    php -r '$foo = ini_get("max_execution_time"); var_dump($foo);' | grep 'string(1) "0"'
    CHECK_RESULT $?
    php -d max_execution_time=20 -r '$foo = ini_get("max_execution_time"); var_dump($foo);' | grep 'string(2) "20"'
    CHECK_RESULT $?
    php -e ../common/my_script.php | grep "PHP test"
    CHECK_RESULT $?
    php -i | grep -E "phpinfo|Configuration|Phar|PHP License"
    CHECK_RESULT $?
    php -l ../common/my_script.php | grep "No syntax errors detected in.*"
    CHECK_RESULT $?
    php -l ../common/test.php | grep "No syntax errors detected in.*"
    CHECK_RESULT $?
    php -m | grep -E "\[PHP Modules\]|\[Zend Modules\]"
    CHECK_RESULT $?
    php -r '$foo = get_defined_constants(); var_dump($foo);' | grep -E "=>|int"
    CHECK_RESULT $?
    find ../common/my_script.php | php -B '$l=0;' -R '$l += count(@file($argn));' -E 'echo "Total Lines: $l\n";' | grep "Total Lines: 8"
    CHECK_RESULT $?
    find ../common/test.php | php -B '$l=0;' -R '$l += count(@file($argn));' -E 'echo "Total Lines: $l\n";' | grep "Total Lines: 95"
    CHECK_RESULT $?
    expect <<EOF
        spawn php -F ../common/my_script.php
        expect "" {send "\r"}
        expect "" {send "\r"}
        expect "" {send "\r"}
        expect "" {send "\04"}
        expect eof
EOF
    php -s ../common/test.php | grep -E "&nbsp|&lt|&gt"
    CHECK_RESULT $?
    php -s ../common/my_script.php | grep -E "&nbsp|&lt|&gt"
    CHECK_RESULT $?
    php -w ../common/my_script.php | grep "<?php echo '<p>Hello World</p>'; ?>"
    CHECK_RESULT $?
    php --ini | grep "ini"
    CHECK_RESULT $?
    php --rf ini_get | grep "function ini_get"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
