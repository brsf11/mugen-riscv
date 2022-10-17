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
# @Author    :   fuyh2020
# @Contact   :   fuyahong@uniontech.com
# @Date      :   2020-09-19
# @License   :   Mulan PSL v2
# @Desc      :   Command test json-c
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "json-c json-c-devel make gcc"
    LOG_INFO "End of environmental preparation!"

}

function run_test() {
    LOG_INFO "Start to run test."

    gcc -o hello test_parse.c -I /usr/include/json-c/ -L /usr/local/bin/ -l json-c
    CHECK_RESULT $? 0 0 "compile file error"

    ./hello > tmp.log
    CHECK_RESULT $? 0 0 "execute hello error"

    grep '{ "Lon": "121.42205", "Lat": "31.32118" }' tmp.log
    CHECK_RESULT $? 0 0 "query msg error"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    rm -f tmp.log hello 
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"

}
main "$@"
