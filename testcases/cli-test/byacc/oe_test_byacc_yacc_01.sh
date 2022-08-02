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

    yacc -V 2>&1 | grep "yacc - " | grep '[[:digit:]]*'
    CHECK_RESULT $? 0 0 "Failed option: -V"

    yacc -b ./tmp/test_b ./common/test.y 
    test -f ./tmp/test_b.tab.c
    CHECK_RESULT $? 0 0 "Failed option: -b"

    yacc ./common/test.y -o ./tmp/test_o.tab.c
    test -f ./tmp/test_o.tab.c
    CHECK_RESULT $? 0 0 "Failed option: -o"

    yacc -H ./tmp/test_h.c ./common/test.y -o ./tmp/test_h.c
    test -f ./tmp/test_h.c
    CHECK_RESULT $? 0 0 "Failed option: -H"

    yacc -b ./tmp/test_g -g ./common/test.y -o ./tmp/test_g.dot
    test -f ./tmp/test_g.dot
    CHECK_RESULT $? 0 0 "Failed option: -g"

    yacc -p test_p ./common/test.y -o ./tmp/test_p.tab.c
    cat ./tmp/test_p.tab.c | grep -m 1 "test_p"
    CHECK_RESULT $? 0 0 "Failed option: -p"

    yacc -l ./common/test.y -o ./tmp/test_l.tab.c
    cat ./tmp/test_l.tab.c | grep "#line"
    CHECK_RESULT $? 0 "Failed option: -l" 0 
    yacc --no-lines ./common/test.y -o ./tmp/test_ll.tab.c
    cat ./tmp/test_ll.tab.c | grep "#line"
    CHECK_RESULT $? 0 "Failed option: --no-lines" 0 

    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf ./tmp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"