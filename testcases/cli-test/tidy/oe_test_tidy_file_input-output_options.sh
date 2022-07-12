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
# @Date      :   2022/2/6
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
    # --error-file
    # 将错误和警告写入指定文件
    echo '' | tidy --error-file ./errors_and_warnings
    grep 'Warning' ./errors_and_warnings
    echo 'error-file: true' >./tidyrc
    echo '' | tidy -config ./tidyrc
    grep 'Warning' ./errors_and_warnings
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: error-file"
    # --keep-time
    # 保留源文件的最新修改时间
    echo 'hi' >./sample.html
    original_modification_time="$(stat --format "%Y" ./sample.html)"
    tidy --keep-time true -m ./sample.html
    current_modification_time="$(stat --format "%Y" ./sample.html)"
    [ "${original_modification_time}" = "${current_modification_time}" ]
    CHECK_RESULT $? 0 0 "Failed to use option: --keep-time"
    echo 'keep-time: true' >./tidyrc
    tidy -config ./tidyrc -m ./sample.html
    current_modification_time="$(stat --format "%Y" ./sample.html)"
    [ "${original_modification_time}" = "${current_modification_time}" ]
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: keep-time"
    # --output-file
    # 将处理结果（标记语言代码）写入指定文件
    echo '<h1>hi' | tidy --output-file ./sample.html
    grep '<h1>hi</h1>' ./sample.html
    CHECK_RESULT $? 0 0 "Failed to use option: --output-file"
    echo 'output-file: sample.html' >./tidyrc
    grep '<h1>hi</h1>' ./sample.html
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: output-file"
    # --write-back
    # 指定是否将处理后的结果写回源文件
    echo '<h1>hi' >./sample.html
    tidy --write-back true ./sample.html
    grep '<h1>hi</h1>' ./sample.html
    CHECK_RESULT $? 0 0 "Failed to use option: --write-back"
    echo '<h1>hi' >./sample.html
    echo 'write-back: true' >./tidyrc
    tidy -config ./tidyrc ./sample.html
    grep '<h1>hi</h1>' ./sample.html
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: write-back"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf errors_and_warnings tidyrc sample.html true
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
