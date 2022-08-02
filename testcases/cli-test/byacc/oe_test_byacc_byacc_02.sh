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
    test -d tmp || mkdir tmp
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    
    byacc -b ./tmp/test_v -v ./common/test.y 2>&1 && test -f ./tmp/test_v.output
    CHECK_RESULT $? 0 0 "Failed option: -v"

    byacc -t ./common/test.y -o ./tmp/test_t.tab.c 2>&1 && cat ./tmp/test_t.tab.c | grep "#define YYDEBUG 1"
    CHECK_RESULT $? 0 0 "Failed option: -t"

    byacc -r ./common/test.y -o ./tmp/test_r.code.c 2>&1 && test -f ./tmp/test_r.code.c
    CHECK_RESULT $? 0 0 "Failed option: -r"

    byacc -b ./tmp/test_d -d ./common/test.y -o /tmp/test_d.tab.h 2>&1 && test -f ./tmp/test_d.tab.h
    CHECK_RESULT $? 0 0 "Failed option: -d"

    byacc -b ./tmp/test_i -i ./common/test.y -o ./tmp/test_i.tab.i 2>&1 && test -f ./tmp/test_i.tab.i
    CHECK_RESULT $? 0 0 "Failed option: -i"

    byacc -s ./common/test.y -o ./tmp/test_s.tab.c 2>&1 && test -f ./tmp/test_s.tab.c
    CHECK_RESULT $? 0 0 "Failed option: -s"

    byacc -P ./common/test.y -o ./tmp/test_P.tab.c 2>&1 && test -f ./tmp/test_P.tab.c
    CHECK_RESULT $? 0 0 "Failed option: -P"

    LOG_INFO "Finish test!"

}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf ./tmp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"