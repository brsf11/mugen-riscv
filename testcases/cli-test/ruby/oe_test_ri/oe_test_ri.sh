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
# @Desc      :   verify the uasge of ri command
# ############################################

source "../common/common_ruby.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL rubygem-rdoc
    gem install webrick
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ri --help | grep "Usage: ri"
    CHECK_RESULT $?
    ri --version | grep "[0-9]"
    CHECK_RESULT $?
    expect <<EOF
        log_file result1
        spawn ri --server
        sleep 5
        expect " " {send "\03"}
        expect eof
EOF
    grep -iE "info|HTTPServer" result1
    CHECK_RESULT $?
    ri --list-doc-dirs | grep -E "/usr/share/ri|/root/.rdoc"
    CHECK_RESULT $?
    expect <<EOF
        log_file result2
        spawn ri --profile
        expect ">> " {send "\r"}
        expect eof
EOF
    grep "[0-9]" result2
    CHECK_RESULT $?
    rdoc ../common/main.rb --format=ri | grep "Parsing sources"
    CHECK_RESULT $?
    test -f doc/cache.ri
    CHECK_RESULT $?
    ri --dump=doc/cache.ri | grep -E "Object|:"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    delete_files
    gem uninstall webrick
    rm -rf /usr/share/ri/site
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@
