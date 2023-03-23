#! /usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   xiechangyan1
# @Contact   :   xiechangyan@uniontech.com
# @Date      :   2022-11-10
# @License   :   Mulan PSL v2
# @Desc      :   Test pcre use
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8
    DNF_INSTALL "pcre pcre-devel"
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pcre-config --version
    CHECK_RESULT $? 0 0 "Pcre is not installed"
    echo '/usr/local/lib/pcre' >> /etc/ld.so.conf
    ldconfig
    CHECK_RESULT $? 0 0 "check your file configuration (/etc/ld.so.conf)"
    cat > pcre.c << EOF
#include <pcre.h>
#include <stdio.h>
int main()
{
  printf("aaa");
  return 0;
}
EOF
    CHECK_RESULT $? 0 0 "check your file configuration (file.c)"
    gcc -I/usr/local/include/pcre -L/usr/local/lib/pcre -lpcre pcre.c
    CHECK_RESULT $? 0 0 "check your file configuration"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to clean the test environment."
    sed '2,$d' /etc/ld.so.conf
    rm -f $(realpath pcre.c) && rm -f $(realpath a.out)
    export LANG=${OLD_LANG}
    LOG_INFO "End to clean the test environment."
}

main "$@"
