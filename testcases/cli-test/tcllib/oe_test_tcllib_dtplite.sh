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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/10/16
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in tcllib package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "tcllib xinetd"
    sed -i '6s/yes/no/g' /etc/xinetd.d/echo-stream
    systemctl restart xinetd
    current_path=$(
        cd "$(dirname $0)" || exit 1
        pwd
    )
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    dtplite -o ${current_path} html example.doc
    CHECK_RESULT $?
    grep "example " example.html && rm -rf example.html
    CHECK_RESULT $?
    mkdir doc || exit 1
    cp example.doc doc/
    dtplite -o ${current_path} -merge html ${current_path}/doc | grep "example.doc"
    CHECK_RESULT $?
    grep "doc/files/example.html" toc.html && rm -rf toc.html doc/
    CHECK_RESULT $?
    dtplite -o ${current_path} -raw html example.doc
    CHECK_RESULT $?
    grep "<title>" example.html
    CHECK_RESULT $? 0 1
    dtplite -o ${current_path} -ext ext html example.doc
    CHECK_RESULT $?
    grep "text/css" example.ext
    CHECK_RESULT $?
    dtplite -o ${current_path} -style example.doc html example.doc
    CHECK_RESULT $?
    grep "style" example.html
    CHECK_RESULT $?
    dtplite -o ${current_path} -header example.doc html example.doc
    CHECK_RESULT $?
    grep "<body>\[manpage_begin" example.html
    CHECK_RESULT $?
    dtplite -o ${current_path} -footer example.doc html example.doc
    CHECK_RESULT $?
    grep "manpage" example.html
    CHECK_RESULT $?
    dtplite -o ${current_path} -module example.doc html example.doc
    CHECK_RESULT $?
    grep "example.doc" example.html
    CHECK_RESULT $?
    dtplite -o exampledoc -nav example.doc https://www.baidu.com html example.doc
    CHECK_RESULT $?
    grep "https://www.baidu.com" exampledoc
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf $(ls | grep -vE ".sh|example.doc|calculator.peg") ./.idx ./.tocdoc ./.xrf ./.toc
    LOG_INFO "End to restore the test environment."
}

main "$@"
