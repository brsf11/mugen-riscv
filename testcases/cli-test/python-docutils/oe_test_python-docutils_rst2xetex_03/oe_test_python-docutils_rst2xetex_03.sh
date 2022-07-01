#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
#@Date      	:   2020-10-19
#@License   	:   Mulan PSL v2
#@Desc      	:   The command rst2xetex parameter coverage test of the python-docutils package
#####################################

source "${OET_PATH}"/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "python-docutils"
    cp -r ../common/testfile_tex.rst ./testfile.rst
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2xetex --documentclass=ctexart testfile.rst test1.tex && grep 'ctexart' test1.tex
    CHECK_RESULT $?
    rst2xetex --documentoptions=UTF8 testfile.rst test2_1.tex && grep 'UTF8' test2_1.tex
    CHECK_RESULT $?
    rst2xetex --documentoptions=a4paper,UTF8 testfile.rst test2_2.tex && grep 'a4paper,UTF8' test2_2.tex
    CHECK_RESULT $?
    rst2xetex --strip-class=multiple testfile.rst test4.tex
    CHECK_RESULT $?
    grep multiple test4.tex
    CHECK_RESULT $? 0 1
    rst2xetex --language=fr testfile.rst test5.tex
    CHECK_RESULT $?
    grep "french" test5.tex
    CHECK_RESULT $?
    rst2xetex --record-dependencies=recordlist.log testfile.rst test6.tex && test -f test6.tex
    CHECK_RESULT $?
    test "$(rst2xetex -V | awk '{print$3}')" == "$(rpm -qa python3-docutils | awk -F "-" '{print$3}')"
    CHECK_RESULT $?
    rst2xetex -h | grep 'Usage'
    CHECK_RESULT $?
    rst2xetex --no-doc-title testfile.rst test8.tex && test -f test8.tex
    CHECK_RESULT $?
    rst2xetex --no-doc-info testfile.rst test9.tex && test -f test9.tex
    CHECK_RESULT $?
    rst2xetex --section-subtitles testfile.rst test10.tex && test -f test10.tex
    CHECK_RESULT $?
    rst2xetex --no-section-subtitles testfile.rst test11.tex && test -f test11.tex
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ./*.tex ./*.rst ./*.log ./*.sty
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
