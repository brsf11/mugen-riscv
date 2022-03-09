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
    # --ascii-chars
    # 与 -clean 搭配使用，将某些字符实体转换为最相近的 ASCII 字符
    echo '&#8211;' | tidy -clean --ascii-chars true | grep '-'
    CHECK_RESULT $? 0 0 "Failed to use option: --ascii-chars"
    echo 'ascii-chars: true' >./tidyrc
    echo '&#8211;' | tidy -clean -config ./tidyrc | grep '-'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: ascii-chars"
    # --ncr
    # 是否允许使用数字引用
    echo '&#931;' | tidy --ncr false | grep '#931'
    CHECK_RESULT $? 0 0 "Failed to use option: --ncr"
    echo 'ncr: false' >./tidyrc
    echo '&#931;' | tidy -config ./tidyrc | grep '#931'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: ncr"
    # --numeric-entities
    # 是否以数字而非名字输出 HTML 实体
    echo '&nbsp;' | tidy --numeric-entities true | grep '&#160;'
    CHECK_RESULT $? 0 0 "Failed to use option: --numeric-entities"
    echo 'numeric-entities: true' >./tidyrc
    echo '&nbsp;' | tidy -config ./tidyrc | grep '&#160;'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: numeric-entities"
    # --preserve-entities
    # 是否应该保留格式良好的实体。
    echo '&nbsp;' | tidy --preserve-entities true | grep '&nbsp;'
    CHECK_RESULT $? 0 0 "Failed to use option: --preserve-entities"
    echo 'preserve-entities: true' >./tidyrc
    echo '&nbsp;' | tidy -config ./tidyrc | grep '&nbsp;'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: preserve-entities"
    # --quote-ampersand
    # 是否输出 & 符号而非其实体格式，默认开启
    echo '&amp;' | tidy --quote-ampersand false | grep '&amp;'
    CHECK_RESULT $? 0 0 "Failed to use option: --quote-ampersand"
    echo 'quote-ampersand: false' >./tidyrc
    echo '&amp;' | tidy -config ./tidyrc | grep '&amp;'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: quote-ampersand"
    # --quote-marks
    # 是否输出"符号的非实体格式，默认关闭
    echo '"' | tidy --quote-marks true | grep '&quot;'
    CHECK_RESULT $? 0 0 "Failed to use option: --quote-marks"
    echo 'quote-marks: true' >./tidyrc
    echo '"' | tidy -config ./tidyrc | grep '&quot;'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: quote-marks"
    # --quote-nbsp
    # 是否以实体格式输出非换行空格，默认开启
    echo '&nbsp;' | tidy --quote-nbsp false | grep 'nbsp'
    CHECK_RESULT $? 1 0 "Failed to use option: --quote-nbsp"
    echo 'quote-nbsp: false' >./tidyrc
    echo '&nbsp;' | tidy -config ./tidyrc | grep 'nbsp'
    CHECK_RESULT $? 1 0 "Failed to use option in configuration: quote-nbsp"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -f ./tidyrc
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
