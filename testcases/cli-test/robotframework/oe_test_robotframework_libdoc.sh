#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# ########################################################
# @Author    :   zhanglu626
# @Contact   :   m18409319968@163.com
# @Date      :   2022/01/18
# @License   :   Mulan PSL v2
# @Desc      :   A Python based test automation framework
# ########################################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL "python3-robotframework"
    mkdir robot_zl
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    libdoc encodings.utf_8 list 2>&1 | grep "Decode"
    CHECK_RESULT $? 0 0 "Failed to list the keyword names contained in the library/resource"
    libdoc encodings.utf_8 show 2>&1 | grep "Arguments:"
    CHECK_RESULT $? 0 0 "Failed to display library/resource document"
    libdoc encodings.utf_8 version 2>&1 | grep "N/A"
    CHECK_RESULT $? 0 0 "Failed to display the library version"
    libdoc -f json encodings.utf_8 robot_zl/doc_f.json && test -f robot_zl/doc_f.json
    CHECK_RESULT $? 0 0 "Failed to specify the format of the output file"
    libdoc -f LIBSPEC -s HTML encodings.utf_8 robot_zl/doc_s.html && test -f robot_zl/doc_s.html
    CHECK_RESULT $? 0 0 "Failed to specify the document format to use for XML and JSON specification files"
    libdoc -f json -F TEXT encodings.utf_8 robot_zl/doc_F.txt && test -f robot_zl/doc_F.txt
    CHECK_RESULT $? 0 0 "Failed to specify the source document format"
    libdoc -f json -n zll encodings.utf_8 robot_zl/doc_n.json && grep '"name": "zll"' robot_zl/doc_n.json
    CHECK_RESULT $? 0 0 "Failed to set the document library or version resource"
    libdoc -f json -v 10086 encodings.utf_8 robot_zl/doc_v.json && grep '"version": "10086"' robot_zl/doc_v.json
    CHECK_RESULT $? 0 0 "Failed to set the document library or version resource"
    libdoc -f json -v 10086 --quiet encodings.utf_8 robot_zl/doc_q.json && test -f robot_zl/doc_q.json
    CHECK_RESULT $? 0 0 "The path to the generated output file is printed to the console"
    libdoc -h 2>&1 | grep "Usage:  libdoc"
    CHECK_RESULT $? 0 0 "Failed to view help information"
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    DNF_REMOVE
    rm -rf robot_zl
    LOG_INFO "Finish environment cleanup."
}

main $@
