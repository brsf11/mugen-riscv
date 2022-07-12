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
# @Date      :   2022/2/5
# @License   :   Mulan PSL v2
# @Desc      :   Test iftop text mode
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL tidy
    OLD_LANG=$LANG
    export LANG="en_US.UTF-8"
    version_id=$(grep VERSION_ID /etc/os-release | awk -F "\"" '{print $2}')
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # --gnu-emacs
    # 默认报错格式
    # line <line number> column <column number> - (Error|Warning): <message>
    # gnu-emacs 开启后的报错格式
    # <filename>:<line number>:<column number>: (Error|Warning): <message>
    echo '<h1>hi' >./sample.html
    tidy --gnu-emacs true ./sample.html 2>&1 | grep 'sample.html' | grep 'Warning'
    CHECK_RESULT $? 0 0 "Failed to use option: --gnu-emacs"
    echo 'gnu-emacs: true' >./tidyrc
    tidy -config ./tidyrc sample.html 2>&1 | grep 'sample.html' | grep 'Warning'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: gnu-emacs"
    # --markup
    # 指定是否要生成格式化后的标记代码，若检测的目标中存在错误，则不生成
    # 该选项默认开启，则在此测试中，检验其关闭后的效果，即不输出处理后的结果
    echo 'hi' | tidy --markup false | grep 'hi'
    CHECK_RESULT $? 1 0 "Failed to use option: --markup"
    echo 'markup: false' >./tidyrc
    echo 'hi' | tidy -config ./tidyrc | grep 'hi'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: markup"
    # --mute
    # 根据 ID 关闭特定错误信息的提示
    echo '' | tidy --mute 'MISSING_TITLE_ELEMENT' 2>&1 | grep "missing 'title' element"
    CHECK_RESULT $? 1 0 "Failed to use option: --mute"
    echo 'mute: MISSING_TITLE_ELEMENT' >./tidyrc
    echo '' | tidy -config ./tidyrc 2>&1 | grep "missing 'title' element"
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: mute"
    # --quiet
    # 对非文档内容的输出做限制，只输出错误和警告，即不输出 Info 等信息
    echo '' | tidy --quiet true 2>&1 | grep 'Info'
    CHECK_RESULT $? 1 0 "Failed to use option:--quiet"
    echo 'quiet: true' >./tidyrc
    echo '' | tidy -config ./tidyrc 2>&1 | grep 'Info'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: quiet"
    # --show-body-only
    # 指定是否只输出 body 标签内的内容
    echo '<head><title>123</title></head><body><h1>hi</h1><body>' | tidy --show-body-only yes | grep '<head>'
    CHECK_RESULT $? 1 0 "Failed to use option: --show-body-only"
    echo 'show-body-only: yes' >./tidyrc
    echo '<head><title>123</title></head><body><h1>hi</h1><body>' | tidy -config ./tidyrc | grep '<head>'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: show-body-only"
    # --show-errors
    # 指定输出几个错误
    echo '<wrong>hi' | tidy --show-errors 0 | grep 'Error: <wrong>'
    CHECK_RESULT $? 1 0 "Failed to use option: --show-errors"
    echo 'show-errors: 0' >./tidyrc
    echo '<wrong>hi' | tidy -config ./tidyrc | grep 'Error: <wrong>'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: show-errors"
    if [ ${version_id} =  "22.03" ]; then
        # --show-filename
        # 在报告中展示文件名
        tidy --show-filename true sample.html 2>&1 | grep 'sample.html'
        CHECK_RESULT $? 0 0 "Failed to use option: show-filename"
        echo 'show-filename: true' >./tidyrc
        tidy -config ./tidyrc sample.html 2>&1 | grep 'sample.html'
        CHECK_RESULT $? 0 0 "Failed to use option in configuration: show-filename"
        # --mute-id
        # 指定是否要在输出的错误提示中包含其对应的 ID
        echo '' | tidy --mute-id true 2>&1 | grep 'title' | grep 'MISSING_TITLE_ELEMENT'
        CHECK_RESULT $? 0 0 "Failed to use option: --mute-id"
        echo 'mute-id: true' >./tidyrc
        echo '' | tidy -config ./tidyrc 2>&1 | grep 'title' | grep 'MISSING_TITLE_ELEMENT'
        CHECK_RESULT $? 0 0 "Failed to use option in configuration: mute-id"
        # --show-filename
        # 输出文件名
        echo '<h1>' >./sample.html
        tidy --show-filename true ./sample.html 2>&1 | grep 'sample.html'
        CHECK_RESULT $? 0 0 "Failed to use option: --show-filename"
        echo 'show-filename: true' >./tidyrc
        tidy -config ./tidyrc ./sample.html 2>&1 | grep 'sample.html'
        CHECK_RESULT $? 0 0 "Failed to use option in configuration: show-filename"
    fi
    # --show-info
    # 指定是否输出 Info 级别的信息，默认开启
    echo '' | tidy --show-info false 2>&1 | grep 'Info'
    CHECK_RESULT $? 1 0 "Failed to use option: --show-info"
    echo 'show-info: false' >./tidyrc
    echo '' | tidy -config ./tidyrc 2>&1 | grep 'Info'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: show-info"
    # --show-warnings
    # 指定是否输出警告信息
    echo '' | tidy --show-warnings false 2>&1 | grep 'Warning'
    CHECK_RESULT $? 1 0 "Failed to use option: --show-warnings"
    echo 'show-warnings: false' >./tidyrc
    echo '' | tidy -config ./tidyrc 2>&1 | grep 'Warning'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: show-warnings"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf tidyrc sample.html
    export LANG=$OLD_LANG
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
