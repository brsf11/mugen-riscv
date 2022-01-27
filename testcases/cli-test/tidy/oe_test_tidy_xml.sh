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
    # -xml-help
    # 以 XML 格式输出命令行选项
    tidy -xml-help | grep 'help'
    CHECK_RESULT $? 0 0 "Failed to use option: -xml-help"
    # -xml-config
    # 以 XML 格式输出配置选项
    tidy -xml-config | grep 'option'
    CHECK_RESULT $? 0 0 "Failed to use option: -xml-config"
    # -xml-strings
    # 以 XML 格式输出 Tidy 的字符串
    tidy -xml-strings | grep 'string'
    CHECK_RESULT $? 0 0 "Failed to use option: -xml-strings"
    # -xml-error-strings
    # 以 XML 格式输出错误常熟和字符串
    tidy -xml-error-strings | grep 'error_string'
    CHECK_RESULT $? 0 0 "Failed to use option: -xml-error-string"
    # -xml-options-strings
    # 以 XML 格式输出选项描述
    tidy -xml-options-strings | grep 'option'
    CHECK_RESULT $? 0 0 "Failed to use option: -xml-options-strings"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
