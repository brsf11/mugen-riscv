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
# @Date      :   2022/2/18
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
    # --break-before-br
    # 在 <br> 前插入换行
    echo 'hi<br>' | tidy --break-before-br true | grep '<br>' -B 1 | grep 'hi'
    CHECK_RESULT $? 0 0 "Failed to use option: --break-before-br"
    echo 'break-before-br: true' >./tidyrc
    echo 'hi<br>' | tidy -config ./tidyrc | grep '<br>' -B 1 | grep 'hi'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: break-before-br"
    # --indent
    echo '<h1>hi</h1>' | tidy --indent true | grep '<h1>' -A1 | grep 'hi'
    CHECK_RESULT $? 0 0 "Failed to use option: --indent"
    echo 'indent: true' >./tidyrc
    echo '<h1>hi</h1>' | tidy -config ./tidyrc | grep '<h1>' -A1 | grep 'hi'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: indent"
    # --indent-attributes
    # 每个特性在一个新的行里
    echo '<p id="1" class="2">hi</p>' | tidy --indent-attributes true | grep 'id' -A 1 | grep 'class'
    CHECK_RESULT $? 0 0 "Failed to use option: --indent-attributes"
    echo 'indent-attributes: true' >./tidyrc
    echo '<p id="1" class="2">hi</p>' | tidy -config ./tidyrc | grep 'id' -A 1 | grep 'class'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: indent-attributes"
    # --indent-cdata
    # --indent-spaces
    # 指定缩进使用的空格数量
    echo '<p>hi<b>what</b></p>' | tidy --indent yes --indent-spaces 1 | grep '<p>' -A 1 | grep ' h'
    CHECK_RESULT $? 0 0 "Failed to use option: --indent-spaces"
    echo 'indent-spaces: 1' >./tidyrc
    echo '<p>hi<b>what</b></p>' | tidy --indent yes -config ./tidyrc | grep '<p>' -A 1 | grep ' h'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: indent-spaces"
    # --indent-with-tabs
    # 使用 tab 来缩进
    echo '<p>hi</p>' | tidy --indent true --indent-with-tabs true | grep -P '\t<p>'
    CHECK_RESULT $? 0 0 "Failed to use option: --indent-with-tabs"
    echo 'indent-with-tabs: true' >./tidyrc
    echo '<p>hi</p>' | tidy --indent true -config ./tidyrc | grep -P '\t<p>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: indent-with-tabs"
    # --keep-tabs
    # --omit-optional-tags
    # 忽略可选标签：<html>、<head>、<body>、</p>、</li>、</dt>、</dd>、</option>、</tr>、 </td> 和 </th>.
    echo 'hi' | tidy --omit-optional-tags true | grep -v '<html>'
    CHECK_RESULT $? 0 0 "Failed to use option: --omit-optional-tags"
    echo 'omit-optional-tags: true' >./tidyrc
    echo 'hi' | tidy -config ./tidyrc | grep -v '<html>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: omit-optional-tags"
    # --priority-attributes
    # 指定特性的优先级
    echo '<p class="a" id="b">hi</p>' | tidy --priority-attributes id | grep '<p id="b" class="a">hi</p>'
    CHECK_RESULT $? 0 0 "Failed to use option: --priority-attributes"
    echo 'priority-attributes: id' >./tidyrc
    echo '<p class="a" id="b">hi</p>' | tidy -config ./tidyrc | grep '<p id="b" class="a">hi</p>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: priority-attributes"
    # --punctuation-wrap
    # --sort-attributes
    # 按制定规则排列特性
    echo '<p id="a" class="b">' | tidy --sort-attributes alpha | grep '<p class="b" id="a"></p>'
    CHECK_RESULT $? 0 0 "Failed to use option: --sort-attributes"
    echo 'sort-attributes: alpha' >./tidyrc
    echo '<p id="a" class="b">' | tidy -config ./tidyrc | grep '<p class="b" id="a"></p>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: sort-attributes"
    # --tab-size
    # --tidy-mark
    # 指定是否在 <head> 中包含 HTML Tidy 相关信息，默认关闭
    echo 'hi' | tidy --tidy-mark false | grep 'HTML Tidy'
    CHECK_RESULT $? 1 0 "Failed to use option: --tidy-mark"
    echo 'tidy-mark: false' >./tidyrc
    echo 'hi' | tidy -config ./tidyrc | grep 'HTML Tidy'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: tidy-mark"
    # --vertical-space
    # 为了可读性，是否添加多余的空行，若设置为 auto，则会删除几乎所有新行的符号。
    echo '<p>Some text</p>' | tidy -indent --vertical-space auto | grep '<p>Some text</p></body></html>'
    CHECK_RESULT $? 0 0 "Failed to use option: --vertical-space"
    echo 'vertical-space: auto' >./tidyrc
    echo '<p>Some text</p>' | tidy -indent -config ./tidyrc | grep '<p>Some text</p></body></html>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: vertical-space"
    if [ ${version_id} =  "22.03" ]; then
        # --wrap
        # 指定Tidy用于换行时的右边距，若设置为0则不换行
        echo 'hi' | tidy --wrap 0 | grep '<meta name="generator" content="HTML Tidy for HTML5 for Linux version'
        CHECK_RESULT $? 0 0 "Failed to use option: --wrap"
    fi
    echo 'wrap: 0' >./tidyrc
    echo 'hi' | tidy -config ./tidyrc | grep '<meta name="generator" content="HTML Tidy for HTML5 for Linux version'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: wrap"
    # --wrap-asp
    # --wrap-attributes
    # --wrap-jste
    # --wrap-php
    # --wrap-script-literals
    # --wrap-sections
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -f ./tidyrc
    export LANG=$OLD_LANG
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
