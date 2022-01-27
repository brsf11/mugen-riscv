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
# @Desc      :   Test tidy document in and output
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL tidy
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # --add-meta-charset
    # 添加一个内容为文档的编码格式的 meta 标签
    echo '' | tidy --add-meta-charset yes | grep '<meta charset="utf-8">'
    CHECK_RESULT $? 0 0 "Failed to use option: --add-meta-charset"
    echo 'add-meta-charset: yes' >./tidyrc
    echo '' | tidy -config ./tidyrc | grep '<meta charset="utf-8">'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: add-meta-charset"
    # --add-xml-decl
    # 添加 XML 文档声明
    echo '' | tidy -asxml --add-xml-decl true | grep 'xml version'
    CHECK_RESULT $? 0 0 "Failed to use option: --add-xml-decl"
    echo 'add-xml-decl: true' >./tidyrc
    echo '' | tidy -asxml -config ./tidyrc | grep 'xml version'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: add-xml-decl"
    # --add-xml-space
    # 给诸如 <pre>、<style> 和 <script> 等标签添加 xml:space="preserve"
    echo '<style>no style</style>' | tidy -asxml --add-xml-space true | grep '<style xml:space="preserve">'
    CHECK_RESULT $? 0 0 "Failed to use option: --add-xml-space"
    echo 'add-xml-space: true' >./tidyrc
    echo '<style>no style</style>' | tidy -asxml -config ./tidyrc | grep '<style xml:space="preserve">'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: add-xml-space"
    # --doctype
    # 指定 Tidy 要生成的 DOCTYPE 声明
    echo '' | tidy --doctype 'strict' | grep '!DOCTYPE' | grep 'DTD'
    CHECK_RESULT $? 0 0 "Failed to use option: --doctype"
    echo 'doctype: strict' >./tidyrc
    echo '' | tidy -config ./tidyrc | grep '!DOCTYPE' | grep 'DTD'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: doctype"
    # --input-xml
    # 指定输入的内容为 XML 格式，则使用 XML 解析器进行处理
    echo '<note>hi</note>' | tidy --input-xml true 2>&1 | grep 'No warnings or errors were found'
    CHECK_RESULT $? 0 0 "Failed to use option: --input-xml"
    echo 'input-xml: true' >./tidyrc
    echo '<note>hi</note>' | tidy -config ./tidyrc 2>&1 | grep 'No warnings or errors were found'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: input-xml"
    # --output-html
    # 指定输出为 HTML
    echo '' | tidy --output-html true | grep '<!DOCTYPE html>'
    CHECK_RESULT $? 0 0 "Failed to use option: --input-xml"
    echo 'output-html: true' >./tidyrc
    echo '' | tidy -config ./tidyrc | grep '<!DOCTYPE html>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: output-html"
    # --output-xhtml
    # 指定输出为 XHTML
    echo '' | tidy --output-xhtml true | grep 'html xmlns'
    CHECK_RESULT $? 0 0 "Failed to use option: --output-xhtml"
    echo 'output-xhtml: true' >./tidyrc
    echo '' | tidy -config ./tidyrc | grep 'html xmlns'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: output-xhtml"
    # --output-xml
    # 指定输出为式良好的 XML
    echo '' | tidy --output-xml true | grep 'content' | grep 'HTML Tidy'
    CHECK_RESULT $? 0 0 "Failed to use option: --output-xml"
    echo 'output-xml: true' >./tidyrc
    echo '' | tidy -config ./tidyrc | grep 'content' | grep 'HTML Tidy'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: output-xml"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -f ./tidyrc
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
