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
    # --accessibility-check
    # 可访问性检查
    # 在等级一中，有一项是对图片是否包含 alt 信息的检查
    echo '<img src="1.jpg"/>' | tidy --accessibility-check 1 2>&1 | grep "<img> missing 'alt' text"
    CHECK_RESULT $? 0 0 "Failed to use option: --accessibility-check"
    echo 'accessibility-check: 1' >./tidyrc
    echo '<img src="1.jpg"/>' | tidy -config ./tidyrc 2>&1 | grep "<img> missing 'alt' text"
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: accessibility-check"
    # --force-output
    # 遇到错误时强制输出
    echo '<hi>' | tidy --force-output true | grep 'body'
    CHECK_RESULT $? 0 0 "Failed to use option: --force-output"
    echo 'force-output: true' >./tidyrc
    echo '<hi>' | tidy -config ./tidyrc | grep 'body'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: force-output"
    # --show-meta-change
    # 当 Tidy 改变文档所用的字符集时输出提示
    echo '<meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">' | tidy --show-meta-change true 2>&1 | grep 'charset' | grep 'replaced'
    CHECK_RESULT $? 0 0 "Failed to use option: --show-meta-change"
    echo 'show-meta-change: true' >./tidyrc
    echo '<meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">' | tidy -config ./tidyrc 2>&1 | grep 'charset' | grep 'replaced'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: show-meta-change"
    # --warn-proprietary-attributes
    # 指定是否对专有特性进行警告，默认开启
    echo '<p what="yes">hi</p>' | tidy --warn-proprietary-attributes false | grep 'Warning' | grep 'what'
    CHECK_RESULT $? 1 0 "Failed to use option: --warn-proprietary-attributes"
    echo 'warn-proprietary-attributes: false' >./tidyrc
    echo '<p what="yes">hi</p>' | tidy -config ./tidyrc | grep 'Warning' | grep 'what'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: warn-proprietary-attributes"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -f ./tidyrc
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
