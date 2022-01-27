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
# @Desc      :   Test tidy processing directives
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL tidy
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # -i, -indent, indent
    # 缩进代码后，<h1> 标签的左侧被插入了一个空格
    echo '<h1>hello' | tidy -i | grep ' <h1>hello</h1>'
    CHECK_RESULT $? 0 0 "Failed to use option: -i"
    echo '<h1>hello' | tidy -indent | grep ' <h1>hello</h1>'
    CHECK_RESULT $? 0 0 "Failed to use option: -indent"
    echo 'indent: auto' >./tidyrc
    echo '<h1>hello' | tidy -config ./tidyrc | grep ' <h1>hello</h1>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: indent"
    # -w, -wrap, wrap
    # 以指定的长度折叠文本内容
    # 根据输出的结果中，单词 Tidy 的同一列，下一行的位置上是否为 application 判断折叠的效果
    echo 'Tidy is a console application for macOS, Linux, Windows, UNIX, and more. It corrects and cleans up HTML and XML documents by fixing markup errors and upgrading legacy code to modern standards.' | tidy -w 30 | grep -A 1 'Tidy' | grep 'application'
    CHECK_RESULT $? 0 0 "Failed to use option: -w"
    echo 'Tidy is a console application for macOS, Linux, Windows, UNIX, and more. It corrects and cleans up HTML and XML documents by fixing markup errors and upgrading legacy code to modern standards.' | tidy -wrap 30 | grep -A 1 'Tidy' | grep 'application'
    CHECK_RESULT $? 0 0 "Failed to use option: -wrap"
    echo 'wrap: 30' >./tidyrc
    echo 'Tidy is a console application for macOS, Linux, Windows, UNIX, and more. It corrects and cleans up HTML and XML documents by fixing markup errors and upgrading legacy code to modern standards.' | tidy -config ./tidyrc | grep -A 1 'Tidy' | grep 'application'
    # -u, -upper, uppercase-tags
    # 标签大写
    echo '' | tidy -u | grep '<HTML>'
    CHECK_RESULT $? 0 0 "Failed to use option: -u"
    echo '' | tidy -upper | grep '<HTML>'
    CHECK_RESULT $? 0 0 "Failed to use option: -upper"
    echo 'uppercase-tags: yes' >./tidyrc
    echo '' | tidy -config ./tidyrc | grep '<HTML>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: uppercase-tags"
    # -c, -clean, clean
    # 清理已弃用的标签
    echo '<center>hello</center>' | tidy -c | grep 'text-align: center'
    CHECK_RESULT $? 0 0 "Failed to use option: -c"
    echo '<center>hello</center>' | tidy -clean | grep 'text-align: center'
    CHECK_RESULT $? 0 0 "Failed to use option: -clean"
    echo 'clean: yes' >./tidyrc
    echo '<center>hello</center>' | tidy -config ./tidyrc | grep 'text-align: center'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: clean"
    # -b, -bare, bare
    # strip out smart quotes and em dashes, etc.
    echo '—' | tidy -b | grep '-'
    CHECK_RESULT $? 0 0 "Failed to use option: -b"
    echo '—' | tidy -bare | grep '-'
    CHECK_RESULT $? 0 0 "Failed to use option: -bare"
    echo 'bare: yes' >./tidyrc
    echo '—' | tidy -config ./tidyrc | grep '-'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: bare"
    # -g, -gdoc, gdoc
    # produce clean version of html exported by Google Docs
    # 对比清理前后，文件的代码量，判断清理的效果
    source_code='<html><head><meta content="text/html; charset=UTF-8" http-equiv="content-type"><style type="text/css">ol{margin:0;padding:0}table td,table th{padding:0}.c2{color:#000000;font-weight:400;text-decoration:none;vertical-align:baseline;font-size:26pt;font-family:"Arial";font-style:normal}.c1{padding-top:0pt;padding-bottom:3pt;line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:center}.c0{background-color:#ffffff;max-width:451.4pt;padding:72pt 72pt 72pt 72pt}.title{padding-top:0pt;color:#000000;font-size:26pt;padding-bottom:3pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:left}.subtitle{padding-top:0pt;color:#666666;font-size:15pt;padding-bottom:16pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:left}li{color:#000000;font-size:11pt;font-family:"Arial"}p{margin:0;color:#000000;font-size:11pt;font-family:"Arial"}h1{padding-top:20pt;color:#000000;font-size:20pt;padding-bottom:6pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:left}h2{padding-top:18pt;color:#000000;font-size:16pt;padding-bottom:6pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:left}h3{padding-top:16pt;color:#434343;font-size:14pt;padding-bottom:4pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:left}h4{padding-top:14pt;color:#666666;font-size:12pt;padding-bottom:4pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:left}h5{padding-top:12pt;color:#666666;font-size:11pt;padding-bottom:4pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:left}h6{padding-top:12pt;color:#666666;font-size:11pt;padding-bottom:4pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;font-style:italic;orphans:2;widows:2;text-align:left}</style></head><body class="c0"><p class="c1 title" id="h.1osv7rxmcj4i"><span class="c2">Hello World</span></p></body></html>'
    # 原始 gdoc 文本的代码数量
    gdoc_char_num=$(echo "${source_code}" | wc -m)
    # 经过 tidy 后的代码数量
    tidied_char_num=$(echo "${source_code}" | tidy -g | wc -m)
    [[ $tidied_char_num -lt $gdoc_char_num ]]
    CHECK_RESULT $? 0 0 "Failed to use option: -g"
    tidied_char_num=$(echo "${source_code}" | tidy -gdoc | wc -m)
    [[ $tidied_char_num -lt $gdoc_char_num ]]
    CHECK_RESULT $? 0 0 "Failed to use option: -gdoc"
    echo 'gdoc: yes' >./tidyrc
    tidied_char_num=$(echo "${source_code}" | tidy -config ./tidyrc | wc -m)
    [[ $tidied_char_num -lt $gdoc_char_num ]]
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: gdoc"
    # -n, -numeric, numeric-entities
    # 是否以数字而非名字输出 HTML 实体
    echo '&nbsp;' | tidy -n | grep '&#160'
    CHECK_RESULT $? 0 0 "Failed to use option: -n"
    echo '&nbsp;' | tidy -numeric | grep '&#160'
    CHECK_RESULT $? 0 0 "Failed to use option: -numeric"
    echo 'numeric-entities: yes' >./tidyrc
    echo '&nbsp;' | tidy -config ./tidyrc | grep '&#160'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: numeric-entities"
    # -e, -errors, markup
    # 只输出错误信息
    echo '' | tidy -e | grep '<html>'
    CHECK_RESULT $? 1 0 "Failed to use option: -e"
    echo '' | tidy -errors | grep '<html>'
    CHECK_RESULT $? 1 0 "Failed to use option: -errors"
    echo 'markup: no' >./tidyrc
    echo '' | tidy -config ./tidyrc | grep '<html>'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: markup"
    # -q, -quiet, quiet
    # 关闭不重要的信息
    echo '' | tidy -q | grep 'Info'
    CHECK_RESULT $? 1 0 "Failed to use option: -q"
    echo '' | tidy -quiet | grep 'Info'
    CHECK_RESULT $? 1 0 "Failed to use option: -quiet"
    echo 'quiet: yes' >./tidyrc
    echo '' | tidy -config ./tidyrc | grep 'Info'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: quiet"
    # -omit, omit-optional-tags
    # 在输出中省略标签： <html>, <head>, <body>, </p>, </li>, </dt>, </dd>, </option>, </tr>, </td>, and </th>.
    # 测试输出结果中是否不存在 <html> 标签，若不存在，则 grep 匹配不到，故 CHECK_RESULT $? 1 0
    echo '' | tidy -omit | grep '<html>'
    CHECK_RESULT $? 1 0 "Failed to use option: -omit"
    echo 'omit-optional-tags: yes' >./tidyrc
    echo '' | tidy -config ./tidyrc | grep '<html>'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: omit-optional-tags"
    # -xml, input-xml
    # 指定输入的内容是格式良好的 XML
    echo '<note><body>hello</body></note>' | tidy -xml 2>&1 | grep 'No warnings or errors were found.'
    CHECK_RESULT $? 0 0 "Failed to use option: -xml"
    echo 'input-xml: yes' >./tidyrc
    echo '<note><body>hello</body></note>' | tidy -config ./tidyrc 2>&1 | grep 'No warnings or errors were found.'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: input-xml"
    # -asxml, -asxhtml (output-xhtml: yes)
    # 输出为 XML
    # 让 tidy 将标签格式化为大写，XML 标准中严格规定元素名必须为小写，则最后的结果为小写
    echo '<p>hello</p>' | tidy -upper -asxml | grep '<p>hello</p>'
    CHECK_RESULT $? 0 0 "Failed to use option: -asxml"
    echo '<p>hello</p>' | tidy -upper -asxhtml | grep '<p>hello</p>'
    CHECK_RESULT $? 0 0 "Failed to use option: -asxhtml"
    echo 'output-xhtml: yes' >./tidyrc
    echo '<p>hello</p>' | tidy -upper -config ./tidyrc | grep '<p>hello</p>'
    CHECK_RESULT $? 0 0 "Failed to use option: output-xhtml"
    # -ashtml, output-html
    # 将 XHTML 转换为 HTML
    # 此功能疑似有问题
    # https://github.com/htacg/tidy-html5/issues/767
    # -access, accessibility-check
    # 可访问性检查
    # 在等级一中，有一项是对图片是否包含 alt 信息的检查
    echo '<img src="1.jpg"/>' | tidy -access 1 2>&1 | grep "<img> missing 'alt' text"
    CHECK_RESULT $? 0 0 "Failed to use option: -access"
    echo 'accessibility-check: 1' >./tidyrc
    echo '<img src="1.jpg"/>' | tidy -config ./tidyrc 2>&1 | grep "<img> missing 'alt' text"
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: accessibility-check"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -f ./tidyrc
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
