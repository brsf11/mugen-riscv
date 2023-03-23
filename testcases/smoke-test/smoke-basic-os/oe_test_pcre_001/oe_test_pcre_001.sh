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
# @Date      :   2022-11-15
# @License   :   Mulan PSL v2
# @Desc      :   Use pcre to compile c programs
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "pcre pcre-devel pcre-help"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    pcre-config --version
    CHECK_RESULT $? 0 0 "The current pcre version cannot be recognized. Please download it again"
    echo "/usr/share/doc/pcre" >>/etc/ld.so.conf
    CHECK_RESULT $? 0 0 "Import library files into cache"
    ldconfig
    CHECK_RESULT $? 0 0 "Run failed from ldconfig"
    cat >file.c <<EOF
#include <pcre.h>
#include <stdio.h>
int main()
{
        printf("aaa");
        return 0;
}
EOF
    gcc -I/usr/local/include/pcre -L/usr/local/lib/pcre -lpcre file.c
    CHECK_RESULT $? 0 0 "Compilation fails"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf file.c
    sed -i '$d' /etc/ld.so.conf
    LOG_INFO "Finish environment cleanup!"
}

main $@
