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
# @Date      :   2022/1/24
# @License   :   Mulan PSL v2
# @Desc      :   Test tidy file manipulation
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL tidy
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # -o, -output, output-file
    # 将处理结果写入指定文件
    echo '<h1>hello' | tidy -o ./tidied.html
    grep '<h1>hello</h1>' ./tidied.html
    CHECK_RESULT $? 0 0 "Failed to use option: -o"
    echo '<h1>hello' | tidy -output ./tidied.html
    grep '<h1>hello</h1>' ./tidied.html
    CHECK_RESULT $? 0 0 "Failed to use option: -output"
    echo 'output-file: tidied.html' >./tidyrc
    echo '<h1>hello' | tidy -config ./tidyrc
    grep '<h1>hello</h1>' ./tidied.html
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: output-file"
    # -config
    # 使用指定的配置文件
    echo 'add-meta-charset: yes' >./tidyrc
    echo '<h1>hello' | tidy -config ./tidyrc | grep '<meta charset=".*">'
    CHECK_RESULT $? 0 0 "Failed to use option: -config"
    # -f, -file, error-file
    # 将错误和警告写入指定文件
    echo '<h1>hello' | tidy -f ./errors_and_warnings
    grep 'Warning' ./errors_and_warnings
    CHECK_RESULT $? 0 0 "Failed to use option: -f"
    echo '<h1>hello' | tidy -file ./errors_and_warnings
    grep 'Warning' ./errors_and_warnings
    CHECK_RESULT $? 0 0 "Failed to use option: -file"
    echo 'error-file: errors_and_warnings' >./tidyrc
    echo '<h1>hello' | tidy -config ./tidyrc
    grep 'Warning' ./errors_and_warnings
    CHECK_RESULT $? 0 0 "Failed to use option: -file"
    # -m, -modify, write-back
    # 将处理过的结果写入源文件
    echo '<h1>hello' >sample.html
    tidy -m ./sample.html
    grep '<h1>hello</h1>' ./tidied.html
    CHECK_RESULT $? 0 0 "Failed to use option: -m"
    echo '<h1>hello' >sample.html
    tidy -modify ./sample.html
    grep '<h1>hello</h1>' ./tidied.html
    CHECK_RESULT $? 0 0 "Failed to use option: -modify"
    echo 'write-back: yes' >./tidyrc
    echo '<h1>hello' >sample.html
    tidy -config ./tidyrc ./sample.html
    grep '<h1>hello</h1>' ./tidied.html
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: write-back"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf errors_and_warnings tidyrc tidied.html sample.html
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
