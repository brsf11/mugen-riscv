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
    VERSION_ID=$(grep "VERSION_ID" /etc/os-release | awk -F '\"' '{print$2}')
    if [ $VERSION_ID != "22.03" ]; then
      path_rdoc=/root/.rdoc
    else
      path_rdoc=/root/.local/share/rdoc
    fi
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rdoc --version | grep "[0-9]"
    CHECK_RESULT $?
    rdoc --help | grep "Usage: rdoc"
    CHECK_RESULT $?
    rdoc -V ../common/main.rb | grep "Parsing sources"
    CHECK_RESULT $?
    test -d doc && rm -rf doc
    rdoc -q ../common/main.rb
    CHECK_RESULT $?
    test -d doc && rm -rf doc
    rdoc ../common/main.rb --write-options
    CHECK_RESULT $?
    rdoc ../common/main.rb --dry-run | grep "Parsing sources"
    CHECK_RESULT $?
    test -d doc
    CHECK_RESULT $? 1
    rdoc ../common/main.rb -D
    CHECK_RESULT $?
    test -d doc && rm -rf doc
    rdoc ../common/main.rb --ignore-invalid | grep "Parsing sources"
    CHECK_RESULT $?
    rdoc ../common/main.rb -r | grep "Parsing sources"
    CHECK_RESULT $?
    test -d $path_rdoc/Customer
    CHECK_RESULT $?
    test -f $path_rdoc/cache.ri -a -f $path_rdoc/created.rid
    CHECK_RESULT $?
    rdoc ../common/main.rb -R | grep "Parsing sources"
    CHECK_RESULT $?
    test -d /usr/share/ri/site/Customer
    CHECK_RESULT $?
    test -f /usr/share/ri/site/cache.ri -a -f /usr/share/ri/site/created.rid
    CHECK_RESULT $?
    rdoc ../common/main.rb -c "UTF-8"
    CHECK_RESULT $?
    grep "UTF-8" doc/index.html
    CHECK_RESULT $?
    grep "UTF-8" doc/Customer.html
    CHECK_RESULT $?
    grep "UTF-8" doc/table_of_contents.html
    CHECK_RESULT $?
    rm -rf doc
    rdoc ../common/main.rb -A
    CHECK_RESULT $?
    test -d doc
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    delete_files
    rm -rf /root/.rdoc/ .rdoc_options /usr/share/ri/site /root/.local
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
