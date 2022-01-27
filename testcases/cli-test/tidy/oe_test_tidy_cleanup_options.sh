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
# @Desc      :   Test tidy clean options
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL tidy
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # --bare
    # strip out smart quotes and em dashes, etc.
    echo '—' | tidy --bare true | grep '-'
    CHECK_RESULT $? 0 0 "Failed to use option: --bare"
    echo 'bare: true' >./tidyrc
    echo '—' | tidy -config ./tidyrc | grep '-'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: bare"
    # --clean
    # 清理已弃用的标签
    echo '<center>hello</center>' | tidy --clean true | grep 'text-align: center'
    CHECK_RESULT $? 0 0 "Failed to use option: --clean"
    echo 'clean: true' >./tidyrc
    echo '<center>hello</center>' | tidy -config ./tidyrc | grep 'text-align: center'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: clean"
    # --drop-empty-elements
    # 移除空元素，默认开启
    echo '<h1></h1>' | tidy --drop-empty-elements false | grep '<h1></h1>'
    CHECK_RESULT $? 0 0 "Failed to use option: --drop-empty-elements"
    echo 'drop-empty-elements: false' >./tidyrc
    echo '<p></p>' | tidy -config ./tidyrc | grep '<p></p>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: drop-empty-elements"
    # --drop-empty-paras
    # 移除空段落（<p> 标签），默认开启
    echo '<p></p>' | tidy --drop-empty-paras false | grep '<p></p>'
    CHECK_RESULT $? 0 0 "Failed to use option: --drop-empty-paras"
    echo 'drop-empty-paras: false' >./tidyrc
    echo '<p></p>' | tidy -config ./tidyrc | grep '<p></p>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: drop-empty-paras"
    # --drop-proprietary-attributes
    # 丢弃专有特性
    echo '<p what="yes">hi</p>' | tidy --drop-proprietary-attributes true | grep 'what'
    CHECK_RESULT $? 1 0 "Failed to use option: --drop-proprietary-attributes"
    echo 'drop-proprietary-attributes: true' >./tidyrc
    echo '<p what="yes">hi</p>' | tidy -config ./tidyrc | grep 'what'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: drop-proprietary-attributes"
    # --gdoc
    # 对比清理前后，文件的代码量，判断清理的效果
    source_code='<html><head><meta content="text/html; charset=UTF-8" http-equiv="content-type"><style type="text/css">ol{margin:0;padding:0}table td,table th{padding:0}.c2{color:#000000;font-weight:400;text-decoration:none;vertical-align:baseline;font-size:26pt;font-family:"Arial";font-style:normal}.c1{padding-top:0pt;padding-bottom:3pt;line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:center}.c0{background-color:#ffffff;max-width:451.4pt;padding:72pt 72pt 72pt 72pt}.title{padding-top:0pt;color:#000000;font-size:26pt;padding-bottom:3pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:left}.subtitle{padding-top:0pt;color:#666666;font-size:15pt;padding-bottom:16pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:left}li{color:#000000;font-size:11pt;font-family:"Arial"}p{margin:0;color:#000000;font-size:11pt;font-family:"Arial"}h1{padding-top:20pt;color:#000000;font-size:20pt;padding-bottom:6pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:left}h2{padding-top:18pt;color:#000000;font-size:16pt;padding-bottom:6pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:left}h3{padding-top:16pt;color:#434343;font-size:14pt;padding-bottom:4pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:left}h4{padding-top:14pt;color:#666666;font-size:12pt;padding-bottom:4pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:left}h5{padding-top:12pt;color:#666666;font-size:11pt;padding-bottom:4pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;orphans:2;widows:2;text-align:left}h6{padding-top:12pt;color:#666666;font-size:11pt;padding-bottom:4pt;font-family:"Arial";line-height:1.15;page-break-after:avoid;font-style:italic;orphans:2;widows:2;text-align:left}</style></head><body class="c0"><p class="c1 title" id="h.1osv7rxmcj4i"><span class="c2">Hello World</span></p></body></html>'
    # 原始 gdoc 文本的代码数量
    gdoc_char_num=$(echo "${source_code}" | wc -m)
    # 经过 tidy 后的代码数量
    tidied_char_num=$(echo "${source_code}" | tidy --gdoc true | wc -m)
    [[ $tidied_char_num -lt $gdoc_char_num ]]
    CHECK_RESULT $? 0 0 "Failed to use option: --gdoc"
    echo 'gdoc: true' >./tidyrc
    tidied_char_num=$(echo "${source_code}" | tidy -config ./tidyrc | wc -m)
    [[ $tidied_char_num -lt $gdoc_char_num ]]
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: gdoc"
    # --logical-emphasis
    # 将 <i>、<em> 和 <b> 标签替换为 <strong> 标签
    echo '<b>hi</b>' | tidy --logical-emphasis true | grep '<strong>hi</strong>'
    CHECK_RESULT $? 0 0 "Failed to use option: --logical-emphasis"
    echo 'logical-emphasis: true' >./tidyrc
    echo '<b>hi</b>' | tidy -config ./tidyrc | grep '<strong>hi</strong>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: logical-emphasis"
    # --merge-divs
    # 与 -clean 搭配使用，默认开启，用于清理嵌套的 <div> 标签
    echo '<div><div>hi</div></div>' | tidy -clean --merge-divs no | grep -c '/div' | grep '2'
    CHECK_RESULT $? 0 0 "Failed to use option: --merge-divs"
    echo 'merge-divs: no' >./tidyrc
    echo '<div><div>hi</div></div>' | tidy -config ./tidyrc | grep -c '/div' | grep '2'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: merge-divs"
    # -merge-spans
    # 与 -clean 搭配使用，默认开启，用于清理嵌套的 <span> 标签
    echo '<span><span>hi</span></span>' | tidy -clean --merge-spans false | grep '<span><span>hi</span></span>'
    CHECK_RESULT $? 0 0 "Failed to use option: --merge-spans"
    echo 'merge-spans: false' >./tidyrc
    echo '<span><span>hi</span></span>' | tidy -config ./tidyrc | grep '<span><span>hi</span></span>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: merge-spans"
    # --word-2000
    # 无法使用
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -f ./tidyrc
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
