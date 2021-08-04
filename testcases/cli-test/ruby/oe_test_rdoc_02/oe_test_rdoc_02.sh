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
# @Date      :   2020/11/20
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of rdoc command
# ############################################

source "../common/common_ruby.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL rubygem-rdoc
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rdoc ../common/main.rb --main=test | grep -E "Parsing sources|doc"
    CHECK_RESULT $?
    test -d doc && rm -rf doc
    rdoc ../common/main.rb -N | grep "/common/main.rb"
    CHECK_RESULT $?
    test -d doc && rm -rf doc
    rdoc ../common/main.rb -H | grep "Parsing sources"
    CHECK_RESULT $?
    test -d doc && rm -rf doc
    rdoc ../common/main.rb --template=test | grep -E "Total|4"
    CHECK_RESULT $?
    test -d doc && rm -rf doc
    rdoc ../common/main.rb --template-stylesheets=../common/main.rb | grep "Parsing sources"
    CHECK_RESULT $?
    grep -i "customer" doc/main.rb
    CHECK_RESULT $?
    rdoc ../common/main.rb -t "my rdoc document" | grep "Parsing sources"
    CHECK_RESULT $?
    grep "my rdoc document" doc/index.html
    CHECK_RESULT $?
    grep "my rdoc document" doc/Customer.html
    CHECK_RESULT $?
    grep "my rdoc document" doc/table_of_contents.html
    CHECK_RESULT $?
    mkdir testdoc && touch testdoc/testfile1 testdoc/testfile2
    CHECK_RESULT $?
    rdoc ../common/main.rb --copy-files=testdoc/ | grep "Parsing sources"
    CHECK_RESULT $?
    test -f doc/testfile1 -a -f doc/testfile2 && rm -rf doc
    rdoc ../common/main.rb --format=pot | grep "Parsing sources"
    CHECK_RESULT $?
    test -f doc/created.rid -a -f doc/rdoc.pot && rm -rf doc
    rdoc ../common/main.rb --format=ri | grep "Parsing sources"
    CHECK_RESULT $?
    test -f doc/cache.ri && rm -rf doc
    rdoc ../common/main.rb -C2 | grep -iE "in file|class Customer|def"
    CHECK_RESULT $?
    rdoc ../common/main.rb --coverage-report | grep -iE "in file|class Customer|def"
    CHECK_RESULT $?
    test -d doc
    CHECK_RESULT $? 1
    rdoc ../common/main.rb --op=mydoc/ | grep "Parsing sources"
    CHECK_RESULT $?
    test -d mydoc
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    delete_files
    rm -rf /root/.rdoc/ .rdoc_options
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
