#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   gaoshuaishuai
# @Contact   :   gaoshuaishuai@uniontech.com
# @Date      :   2022-11-23
# @License   :   Mulan PSL v2
# @Desc      :   package expat test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL expat
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start testing..."
    cat > test1.xml <<EOF
<root>
<name>test</name>
<from>741423</from>
</root>
EOF    
    CHECK_RESULT $? 0 0 "test1.xml failed to add content"
    xmlwf test1.xml
    CHECK_RESULT $? 0 0 "xmlwf test1 failed" 
    cat > test2.xml <<EOF
<roots>
<name>test</name>
<from>741423</from>
</root>
EOF
    CHECK_RESULT $? 0 0 "test2.xml failed to add content"
    xmlwf test2.xml
    CHECK_RESULT $? 2 0 "Invalid xml execution result error"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf test1.xml test2.xml
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main $@
