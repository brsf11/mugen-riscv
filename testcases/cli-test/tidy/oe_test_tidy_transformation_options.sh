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
# @Date      :   2022/2/17
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
    # --decorate-inferred-ul
    # --escape-cdata
    # 讲 <![CDATA[]]> 的内容转换为普通文本
    echo '<![CDATA[hi]]>' | tidy --escape-cdata true | grep 'hi'
    CHECK_RESULT $? 0 0 "Failed to use option: --escape-cdata"
    echo 'escape-cdata: true' >./tidyrc
    echo '<![CDATA[hi]]>' | tidy -config ./tidyrc | grep 'hi'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: escape-cdata"
    # --hide-comments
    # 不打印注释
    echo '<!--this is comment -->' | tidy --hide-comments true | grep 'this is comment'
    CHECK_RESULT $? 1 0 "Failed to use option: --hide-comments"
    echo 'hide-comments: true' >./tidyrc
    echo '<!--this is comment -->' | tidy -config ./tidyrc | grep 'this is comment'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: hide-comments"
    # --join-classes
    # 将多个类名生成一个新类名
    echo '<p class="a" class="b">hi</p>' | tidy --join-classes true | grep 'class="a b"'
    CHECK_RESULT $? 0 0 "Failed to use option: --join-classes"
    echo 'join-classes: true' >./tidyrc
    echo '<p class="a" class="b">hi</p>' | tidy -config ./tidyrc | grep 'class="a b"'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: join-classes"
    # --join-styles
    # 将多个样式合并为一个新样式
    echo '<h1 style="color:blue" style="text-align:center;">hi</h1>' | tidy --join-styles false | grep 'Warning: <h1> dropping value "color:blue" for repeated attribute "style"'
    CHECK_RESULT $? 1 0 "Failed to use option: --join-styles"
    echo 'join-styles: false' >./tidyrc
    echo '<h1 style="color:blue" style="text-align:center;">hi</h1>' | tidy -config ./tidyrc | grep 'Warning: <h1> dropping value "color:blue" for repeated attribute "style"'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: join-styles"
    echo '<h1 style="color:blue" style="text-align:center;">hi</h1>' | tidy --join-styles true | grep 'Warning: <h1> joining values of repeated attribute "style"'
    CHECK_RESULT $? 1 0 "Failed to use option: --join-styles"
    echo 'join-styles: true' >./tidyrc
    echo '<h1 style="color:blue" style="text-align:center;">hi</h1>' | tidy -config ./tidyrc | grep 'Warning: <h1> joining values of repeated attribute "style"'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: join-styles"
    # --merge-emphasis
    # 合并嵌套的 <b> 和 <i> 元素，默认开启
    echo '<b><b>hi</b></b>' | tidy --merge-emphasis false | grep '<b><b>hi</b></b>'
    CHECK_RESULT $? 0 0 "Failed to use option: --merge-emphasis"
    echo 'merge-emphasis: false' >./tidyrc
    echo '<b><b>hi</b></b>' | tidy -config ./tidyrc | grep '<b><b>hi</b></b>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: merge-emphasis"
    # --replace-color
    # 将颜色的数字表示转换为名字
    echo '<font color="#ffffff">hi</font>' | tidy --replace-color true | grep 'color="white"'
    CHECK_RESULT $? 0 0 "Failed to use option: --replace-color"
    echo 'replace-color: true' >./tidyrc
    echo '<font color="#ffffff">hi</font>' | tidy -config ./tidyrc | grep 'color="white"'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: replace-color"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -f ./tidyrc
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
