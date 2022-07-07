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
# @Date      :   2022/2/8
# @License   :   Mulan PSL v2
# @Desc      :   Test tidy repair options
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL tidy
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # --alt-text
    # 当 <img> 标签的 alt 特性为空时，设置默认的填充内容
    echo '<img>' | tidy --alt-text 'description' | grep '<img alt="description">'
    echo '' | tidy --alt-text true | grep ''
    CHECK_RESULT $? 0 0 "Failed to use option: --alt-text"
    echo 'alt-text: description' >./tidyrc
    echo '<img>' | tidy -config ./tidyrc | grep '<img alt="description">'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: alt-text"
    # --anchor-as-name
    # 对于 <a> 标签，有 name 属性，没有 id 属性，则添加
    echo '<a name="2">hi</a>' | tidy --anchor-as-name true | grep 'id="2"'
    CHECK_RESULT $? 0 0 "Failed to use option: --anchor-as-name"
    echo 'anchor-as-name: true' >./tidyrc
    echo '<a name="2">hi</a>' | tidy -config ./tidyrc | grep 'id="2"'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: anchor-as-name"
    # --assume-xml-procins
    # 在解析“处理指令”时，使用 ?> 作为结尾，而非 >
    # 测试时没有明显效果
    # --coerce-endtags
    # 若一个开始标签看起来像结束标签则强制将其转换，默认开启
    # 测试中未成功将此功能关闭，但是输出的信息中额外包含了相关提示
    echo '<b>bar<b>' | tidy --coerce-endtags false 2>&1 | grep 'trimming empty <b>'
    CHECK_RESULT $? 0 0 "Failed to use option: --coerce-endtags"
    echo 'coerce-endtags: false' >./tidyrc
    echo '<b>bar<b>' | tidy -config ./tidyrc 2>&1 | grep 'trimming empty <b>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: coerce-endtags"
    # --css-prefix
    # 将 inline 改写，添加对应的类，用于指定类名，需要与 -clean 搭配
    echo '<font color="#0000FF">blue</font>' | tidy -clean --css-prefix hi | grep 'hi'
    CHECK_RESULT $? 0 0 "Failed to use option: --css-prefix"
    echo 'css-prefix: hi' >./tidyrc
    echo '<font color="#0000FF">blue</font>' | tidy -clean -config ./tidyrc | grep 'hi'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: css-prefix"
    # --custom-tags
    # --enclose-block-text
    # 插入 <p> 标签用以闭合所有符合混合 HTML 过渡的文段
    echo '' | tidy --enclose-block-text true | grep ''
    CHECK_RESULT $? 0 0 "Failed to use option: --enclose-block-text"
    echo 'enclose-block-text: true' >./tidyrc
    echo '' | tidy -config ./tidyrc | grep ''
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: enclose-block-text"
    # --enclose-text
    # 指定是否应将在 body 元素中找到的任何文本包含在 <p> 元素中
    echo 'hi' | tidy --enclose-text true | grep '<p>hi</p>'
    CHECK_RESULT $? 0 0 "Failed to use option: --enclose-text"
    echo 'enclose-text: true' >./tidyrc
    echo 'hi' | tidy -config ./tidyrc | grep '<p>hi</p>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: enclose-text"
    # --escape-scripts
    # --fix-backslash
    # 是否修正 URL 中的反斜杠为正斜杠，默认开启
    echo '<a href="http:\\openeuler.org"></a>' | tidy --fix-backslash false 2>&1 | grep '\\openeuler.org'
    CHECK_RESULT $? 0 0 "Failed to use option: --fix-backslash"
    echo 'fix-backslash: false' >./tidyrc
    echo '<a href="http:\\openeuler.org"></a>' | tidy -config ./tidyrc 2>&1 | grep '\\openeuler.org'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: fix-backslash"
    # --fix-bad-comments
    # 是否替换相连的非预期的连字符为“=”
    echo '<!---hi--->' | tidy --fix-bad-comments true | grep '<!--=hi=-->'
    CHECK_RESULT $? 0 0 "Failed to use option: --fix-bad-comments"
    echo 'fix-bad-comments: true' >./tidyrc
    echo '<!---hi--->' | tidy -config ./tidyrc | grep '<!--=hi=-->'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: fix-bad-comments"
    # --fix-style-tags
    # 是否将所有样式标签移动至 <head> 部分中
    echo '<body><style type="text/css">h1{color: blue}</style></body>' >sample.html
    tidy --fix-style-tags false sample.html | grep 'body' -A 1 | grep 'style'
    CHECK_RESULT $? 0 0 "Failed to use option: --fix-style-tags"
    echo 'fix-style-tags: false' >./tidyrc
    tidy -config ./tidyrc sample.html | grep 'body' -A 1 | grep 'style'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: fix-style-tags"
    # --fix-uri
    # 是否应检查包含 URI 的属性值是否存在非法字符，默认开启
    echo '<a href="http://shangcode.cn/拥抱开源">yeah</a>' | tidy --fix-uri false | grep '拥抱开源'
    CHECK_RESULT $? 0 0 "Failed to use option: --fix-uri"
    echo 'fix-uri: false' >./tidyrc
    echo '<a href="http://shangcode.cn/拥抱开源">yeah</a>' | tidy -config ./tidyrc | grep '拥抱开源'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: fix-uri"
    # --literal-attributes
    # 不忽略除 title、alt、value 之外的所有内容的前导和尾随空格
    echo '<p id="a ">hi</p>' | tidy -q --literal-attributes true | grep '<p id="a ">'
    CHECK_RESULT $? 0 0 "Failed to use option: --literal-attributes"
    echo 'literal-attributes: true' >./tidyrc
    echo '<p id="a ">hi</p>' | tidy -config ./tidyrc | grep '<p id="a ">'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: literal-attributes"
    # --lower-literals
    # --repeated-attributes
    # 保留重复特性中的哪个，第一个或最后一个
    echo '<p align="left" align="right">hi</p>' | tidy --repeated-attributes keep-first | grep 'align="left"'
    CHECK_RESULT $? 0 0 "Failed to use option: --repeated-attributes"
    echo 'repeated-attributes: keep-first' >./tidyrc
    echo '<p align="left" align="right">hi</p>' | tidy -config ./tidyrc | grep 'align="left"'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: repeated-attributes"
    # --join-classes,
    # --join-styles
    # --skip-nested
    # --strict-tags-attributes
    # --uppercase-attributes
    # 将特性大写输出
    echo '<p align="left">hi</p>' | tidy --uppercase-attributes true | grep 'ALIGN="left"'
    CHECK_RESULT $? 0 0 "Failed to use option: --uppercase-attributes"
    echo 'uppercase-attributes: true' >./tidyrc
    echo '<p align="left">hi</p>' | tidy -config ./tidyrc | grep 'ALIGN="left"'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: uppercase-attributes"
    # --uppercase-tags
    # 将标签大写输出
    echo '<p>hi</p>' | tidy --uppercase-tags true | grep '<P>hi</P>'
    CHECK_RESULT $? 0 0 "Failed to use option: --uppercase-tags"
    echo 'uppercase-tags: true' >./tidyrc
    echo '<p>hi</p>' | tidy -config ./tidyrc | grep '<P>hi</P>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: uppercase-tags"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf tidyrc tidied.html sample.html
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
