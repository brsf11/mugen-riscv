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
#@Author    	:   doraemon2020
#@Contact   	:   xcl_job@163.com
#@Date      	:   2020-10-13
#@License   	:   Mulan PSL v2
#@Desc      	:   The command rst2s5 parameter coverage test of the python-docutils package
#####################################
source "${OET_PATH}"/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    cp -r ../common/testfile.rst ./
    DNF_INSTALL "python-docutils"
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2s5 --theme=small-white testfile.rst test1.html &&
        grep 'ui/small-white' test1.html
    CHECK_RESULT $?
    rst2s5 --theme-url=ui/big-white testfile.rst test2.html &&
        grep 'ui/big-white' test2.html
    CHECK_RESULT $?
    rst2s5 --overwrite-theme-files --theme-url=ui/big-white testfile.rst test3.html &&
        grep 'ui/big-white' test3.html
    CHECK_RESULT $?
    rst2s5 --keep-theme-files testfile.rst test4.html
    CHECK_RESULT $?
    rst2s5 --view-mode=outline testfile.rst test5.html &&
        grep 'content="outline"' test5.html
    CHECK_RESULT $?
    rst2s5 --hidden-controls testfile.rst test6.html
    CHECK_RESULT $?
    rst2s5 --visible-controls testfile.rst test7.html &&
        grep 'content="visible"' test7.html
    CHECK_RESULT $?
    rst2s5 --current-slide testfile.rst test8.html &&
        grep '<style type="text/css">' test8.html
    CHECK_RESULT $?
    rst2s5 --no-current-slide testfile.rst test9.html &&
        grep '#currentSlide {display: none;}' test9.html
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./*.html ./*.rst ./*.log ./ui
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
