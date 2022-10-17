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
# @Author    :   geyaning
# @Contact   :   geyaning@uniontech.com
# @Date      :   2022.8.31
# @License   :   Mulan PSL v2
# @Desc      :   add test cmp
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "diffutils"
    local=$(localectl status | grep System | awk -F "=" '{print $2}')
    localectl set-locale LANG=zh_CN.utf8    
    LOG_INFO "End of environmental preparation!"

}
function run_test() {
    LOG_INFO "Start testing..."
    cmp --version
    CHECK_RESULT $? 0 0 "The version information cannot be queried"
    cat > /opt/file1 << EOF
aaa
bbb
ccc
EOF
    cat > /opt/file2 << EOF
aaa
bbb
ccd 
EOF
    CHECK_RESULT $? 0 0 "Failed to create a file"
    cp /opt/file1 /opt/file3
    cmp /opt/file1 /opt/file3
    CHECK_RESULT $? 0 0 "The two files have the same content,but the detection fails"
    cmp /opt/file1 /opt/file2 | grep "不同"
    CHECK_RESULT $? 0 0 "The contents of the files are different,but no difference is detected"
    cmp -l file1 file2 | grep "结束"
    CHECK_RESULT $? 1 0 "Unable to display details"
    LOG_INFO "Finish test!"
}
function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf /opt/file{1,2,3}
    DNF_REMOVE
    localectl set-locale LANG=${local}
    LOG_INFO "Finish environment cleanup!"
}

main $@
