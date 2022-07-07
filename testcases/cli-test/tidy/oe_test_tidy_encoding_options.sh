#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   shangyingjie
# @Contact   :   yingjie@isrc.iscas.ac.cn
# @Date      :   2022/2/7
# @License   :   Mulan PSL v2
# @Desc      :   Test iftop text mode
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL tidy
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # --char-encoding
    # 指定输入内容的编码格式，若设置，则可能会挑选与输入格式不同的输出格式
    echo '½' | tidy --char-encoding ascii | grep '&frac12;'
    CHECK_RESULT $? 0 0 "Failed to use option: --char-encoding"
    echo 'char-encoding: ascii' >./tidyrc
    echo '½' | tidy -config ./tidyrc | grep '&frac12;'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: char-encoding"
    # --input-encoding
    # 指定输入格式
    echo '½' | tidy --input-encoding utf8 | grep '½'
    CHECK_RESULT $? 0 0 "Failed to use option: --input-encoding"
    echo 'input-encoding: utf8' >./tidyrc
    echo '½' | tidy -config ./tidyrc | grep '½'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: input-encoding"
    # --newline
    # 指定新行所使用的标记
    echo '' | tidy --newline CRLF -o ./tidied.html
    file ./tidied.html | grep 'CRLF'
    CHECK_RESULT $? 0 0 "Failed to use option: --newline"
    echo 'newline: CRLF' >./tidyrc
    echo '' | tidy -config ./tidyrc -o ./tidied.html
    file ./tidied.html | grep 'CRLF'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: newline"
    # --output-bom
    # 在输出的开头加入 BOM（字节顺序标记）
    echo '' | tidy --output-bom yes | grep 'DOCTYPE' -b -1 | grep ' '
    CHECK_RESULT $? 0 0 "Failed to use option: --output-bom"
    echo 'output-bom: true' >./tidyrc
    echo '' | tidy -config ./tidyrc | grep 'DOCTYPE' -b -1 | grep ' '
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: output-bom"
    # --output-encoding
    # 指定输出的编码格式
    echo '½' | tidy --output-encoding ASCII | grep '&frac12;'
    CHECK_RESULT $? 0 0 "Failed to use option: --output-encoding"
    echo 'output-encoding: ASCII' >./tidyrc
    echo '½' | tidy -config ./tidyrc | grep '&frac12;'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: output-encoding"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf tidyrc tidied.html
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
