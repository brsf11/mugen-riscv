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
# @Author    :   zuohanxu
# @Contact   :   zuohanxu@uniontech.com
# @Date      :   2022.9.09
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-llvm
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test(){
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "llvm clang"
    mkdir /tmp/test_llvm
    path=/tmp/test_llvm
    cat > /tmp/test_llvm/llvm_test.c   <<EOF
#include <stdio.h>
int main() {
  printf("hello llvm\n");
  return 0;
}
EOF
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    rpm -qa | grep llvm
    CHECK_RESULT $? 0 0 "Installation failed"
    rpm -ql llvm
    CHECK_RESULT $? 0 0 "No path is queried"

    clang ${path}/llvm_test.c -o ${path}/test
    CHECK_RESULT $? 0 0 "compilation fails"
    ls ${path}/test
    CHECK_RESULT $? 0 0 "test does not exist"

    clang -O3 -emit-llvm ${path}/llvm_test.c -c -o ${path}/test.bc
    CHECK_RESULT $? 0 0 "compilation fails"
    ls ${path}/test.bc
    CHECK_RESULT $? 0 0 "test.bc does not exist"

    ${path}/test | grep -w "hello llvm"
    CHECK_RESULT $? 0 0 "test on failure"

    lli ${path}/test.bc | grep -w "hello llvm"
    CHECK_RESULT $? 0 0 "test.bc on failure"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf ${path}
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main $@
