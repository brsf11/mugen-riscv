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
# @Desc      :   Test tidy miscellaneous
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL tidy
    OLD_LANG=$LANG
    export LANG="en_US.UTF-8"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # -v, --version
    tidy -v | grep 'HTML Tidy for Linux version' | grep '[[:digit:]]*'
    CHECK_RESULT $? 0 0 "Failed to use option: -v"
    tidy -version | grep 'HTML Tidy for Linux version' | grep '[[:digit:]]*'
    CHECK_RESULT $? 0 0 "Failed to use option: -version"
    # -h, -help, -help-config
    tidy -h | grep -F 'tidy [options...] [file...] [options...] [file...]'
    CHECK_RESULT $? 0 0 "Failed to use option: -h"
    tidy -help | grep -F 'tidy [options...] [file...] [options...] [file...]'
    CHECK_RESULT $? 0 0 "Failed to use option: -help"
    tidy -? | grep -F 'tidy [options...] [file...] [options...] [file...]'
    CHECK_RESULT $? 0 0 "Failed to use option: -?"
    tidy -help-config | grep 'HTML Tidy Configuration Settings'
    CHECK_RESULT $? 0 0 "Failed to use option: -help-config"
    # -help-env, -help-option
    # 与 tidy 有关的环境变量
    tidy -help-env | grep 'Tidy can configure its option values from multiple sources'
    CHECK_RESULT $? 0 0 "Failed to use option: -help-env"
    tidy -help-option add-meta-charset | grep 'This option, when enabled'
    CHECK_RESULT $? 0 0 "Failed to use option: -help-option"
    # -export-default-config
    # 导出默认的配置
    tidy -export-default-config | grep 'add-meta-charset' | grep 'no'
    CHECK_RESULT $? 0 0 "Failed to use option: -export-default-config"
    # -show-config
    # 展示当前的配置
    echo 'add-meta-charset: yes' >./tidyrc
    tidy -config ./tidyrc -show-config | grep 'add-meta-charset' | grep 'yes'
    CHECK_RESULT $? 0 0 "Failed to use option: -show-config"
    # -export-config
    # 以配置文件的格式展示当前的配置
    tidy -config ./tidyrc -export-config | grep 'add-meta-charset' | grep 'yes'
    CHECK_RESULT $? 0 0 "Failed to use option: -export-config"
    # -language
    # 让 tidy 使用中文进行交互
    echo '<h1>你好</h1>' | tidy -language zh-cn 2>&1 | grep 'Info: 文档内容看起来像 HTML5'
    CHECK_RESULT $? 0 0 "Failed to use option: -language"
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
