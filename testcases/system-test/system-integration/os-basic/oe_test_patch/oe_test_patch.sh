#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   fuyh2020
# @Contact   :   fuyahong@uniontech.com
# @Date      :   2020-08-04
# @License   :   Mulan PSL v2
# @Desc      :   Command test patch -p0/-Rp0
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL patch
    LOG_INFO "End of environmental preparation!"

}

function run_test() {
    LOG_INFO "Start to run test."

    cat > patch_test_old.txt << EOF
old_line_1
old_line_2
EOF
    cat > patch_test_new.txt << EOF
new_line_1
new_line_2
EOF
    diff -Naur patch_test_old.txt patch_test_new.txt > foo.patch
    CHECK_RESULT $? 1 0 "create foo.patch error"
    patch -p0 < foo.patch
    grep new patch_test_old.txt
    CHECK_RESULT $? 0 0 "patch -po error"
    patch -Rp0 < foo.patch
    grep new patch_test_old.txt
    CHECK_RESULT $? 1 0 "patch -Rpo error"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -f  patch_test_old.txt patch_test_new.txt foo.patch
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"

}
main "$@"
