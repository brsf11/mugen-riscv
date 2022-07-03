# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author    	:   zu binshuo
# @Contact   	:   binshuo@isrc.iscas.ac.cn
# @Date      	:   2022-7-15
# @License   	:   Mulan PSL v2
# @Desc      	:   the test of byacc package
####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL byacc
    cp -rf ../common ./tmp
    cd ./tmp
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # TODO
    byacc -v test.y -o test_v.output 2>&1 && ls | grep "test_v.output"
    CHECK_RESULT $? 0 0 "Failed option: -v"

    byacc -t test.y -o test_t.tab.c 2>&1 && cat test_t.tab.c | grep "#define YYDEBUG 1"
    CHECK_RESULT $? 0 0 "Failed option: -t"

    byacc -r test.y -o test_r.code.c 2>&1 && ls | grep "test_r.code.c"
    CHECK_RESULT $? 0 0 "Failed option: -r"

    byacc -d test.y -o test_d.tab.h 2>&1 && ls | grep "test_d.tab.h"
    CHECK_RESULT $? 0 0 "Failed option: -d"

    byacc -i test.y -o test_i.tab.i 2>&1 && ls | grep "test_i.tab.i"
    CHECK_RESULT $? 0 0 "Failed option: -i"

    byacc -s test.y -o test_s.tab.c 2>&1 && ls | grep "test_s.tab.c"
    CHECK_RESULT $? 0 0 "Failed option: -s"

    byacc -P test.y -o test_P.tab.c 2>&1 && ls | grep "test_P.tab.c"
    CHECK_RESULT $? 0 0 "Failed option: -P"

    LOG_INFO "Finish test!"

}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    cd .. && rm -rf ./tmp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"