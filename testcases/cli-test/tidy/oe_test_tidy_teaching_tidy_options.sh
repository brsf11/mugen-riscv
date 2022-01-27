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
    # --new-blocklevel-tags
    # 定义新的块级标签
    echo '<what>hi</what>' | tidy --new-blocklevel-tags what | grep '<what>hi</what>'
    CHECK_RESULT $? 0 0 "Failed to use option: --new-blocklevel-tags"
    echo 'new-blocklevel-tags: what' >./tidyrc
    echo '<what>hi</what>' | tidy -config ./tidyrc | grep '<what>hi</what>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: new-blocklevel-tags"
    # --new-empty-tags
    # 定义新的空内联标签
    echo '<p><what>hi</p>' | tidy --new-empty-tags what | grep '<what>'
    CHECK_RESULT $? 0 0 "Failed to use option: --new-empty-tags"
    echo 'new-empty-tags: what' >./tidyrc
    echo '<p><what>hi</p>' | tidy -config ./tidyrc | grep '<what>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: new-empty-tags"
    # --new-inline-tags
    # 定义新的内联标签
    echo '<p><what>hi<what></p>' | tidy --new-inline-tags what | grep '<p><what>hi</what></p>'
    CHECK_RESULT $? 0 0 "Failed to use option: --new-inline-tags"
    echo 'new-inline-tags: what' >./tidyrc
    echo '<p><what>hi<what></p>' | tidy -config ./tidyrc | grep '<p><what>hi</what></p>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: new-inline-tags"
    # --new-pre-tags
    # 定义新的与格式化标签
    echo '<what_pre>hi</what_pre>' | tidy --new-pre-tags what_pre | grep '<what_pre>hi</what_pre>'
    CHECK_RESULT $? 0 0 "Failed to use option: --new-pre-tags"
    echo 'new-pre-tags: what_pre' >./tidyrc
    echo '<what_pre>hi</what_pre>' | tidy -config ./tidyrc | grep '<what_pre>hi</what_pre>'
    CHECK_RESULT $? 0 0 "Failed to use option in configuration: new-pre-tags"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -f ./tidyrc
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
