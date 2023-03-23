#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   deepin12
# @Contact   :   chenyia@uniontech.com
# @Date      :   2022-12-1
# @License   :   Mulan PSL v2
# @Desc      :   Command test-chgrp 
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    OLD_LANG=$LANG
    export LANG=en_US.UTF-8    
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    touch 1.txt 2.txt
    CHECK_RESULT $? 0 0  "file is created"
    mkdir -p test11/test
    CHECK_RESULT $? 0 0  "directory is created"
    chgrp -v bin 1.txt
    CHECK_RESULT $? 0 0 "command executed fail" 
    ls -l|grep 1.txt|awk '{print$4}'|grep bin
    CHECK_RESULT $? 0 0  "check file group fail"
    chgrp --reference=1.txt 2.txt
    CHECK_RESULT $? 0 0 "command executed fail"
    ls -l|grep 2.txt|awk '{print$4}'|grep bin
    CHECK_RESULT $? 0 0 "check file group fail"
    chgrp -v -R bin test11/
    CHECK_RESULT $? 0 0 "command executed fail"
    ls -ld test11|awk '{print$4}'|grep bin
    CHECK_RESULT $? 0 0  "check file and directory group fail"
    ls -l test11|awk '{print$4}'|grep bin
    CHECK_RESULT $? 0 0  "check file and directory group fail"
    chgrp --help |grep chgrp
    CHECK_RESULT $? 0 0  "check command fail"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -rf 1.txt 2.txt test11
    export LANG=${OLD_LANG}
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
