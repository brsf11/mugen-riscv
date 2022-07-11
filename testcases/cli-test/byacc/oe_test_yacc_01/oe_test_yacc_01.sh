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

    yacc -V 2>&1 | grep "yacc - " | grep '[[:digit:]]*'
    CHECK_RESULT $? 0 0 "Failed option: -v"
    yacc -V 2>&1 | grep "yacc - " | grep '[[:digit:]]*'
    CHECK_RESULT $? 0 0 "Failed option: -v"

    yacc -h 2>&1 | grep 'Usage: yacc'
    CHECK_RESULT $? 0 0 "Failed option: -h"
    yacc --help 2>&1 | grep 'Usage: yacc'
    CHECK_RESULT $? 0 0 "Failed option: --help"

    yacc -b test_b test.y 
    ls | grep "test_b.tab.c" 
    CHECK_RESULT $? 0 0 "Failed option: -b"

    yacc -H test_h.c test.y
    ls | grep "test_h.c" 
    CHECK_RESULT $? 0 0 "Failed option: -H"

    yacc test.y -o test_o.tab.c
    ls | grep "test_o.tab.c"
    CHECK_RESULT $? 0 0 "Failed option: -o"

    yacc -g test.y -o test_g.dot
    ls | grep "test_g.dot"
    CHECK_RESULT $? 0 0 "Failed option: -g"

    yacc -p test_p test.y -o test_p.tab.c
    cat test_p.tab.c | grep -m 1 "test_p"
    CHECK_RESULT $? 0 0 "Failed option: -p"

    yacc -l test.y -o test_l.tab.c
    cat test_l.tab.c | grep "#line"
    CHECK_RESULT $? 0 "Failed option: -l" 0 
    yacc --no-lines test.y -o test_ll.tab.c
    cat test_ll.tab.c | grep "#line"
    CHECK_RESULT $? 0 "Failed option: --no-lines" 0 

    cat /etc/os-release | grep "openEuler 22.03"
    if [ $? ]; then
    yacc --file-prefix test_lb test.y 
    ls | grep "test_lb.tab.c" 
    CHECK_RESULT $? 0 0 "Failed option: --file-prefix"

    yacc --defines test_lh.c test.y
    ls | grep "test_lh.c" 
    CHECK_RESULT $? 0 0 "Failed option: --defines"

    yacc test.y --output test_lo.tab.c
    ls | grep "test_lo.tab.c"
    CHECK_RESULT $? 0 0 "Failed option: --output"
    
    yacc --graph test.y -o test_lg.dot
    ls | grep "test_lg.dot"
    CHECK_RESULT $? 0 0 "Failed option: --graph"

    yacc --name-prefix test_lp test.y -o test_lp.tab.c
    cat test_lp.tab.c | grep -m 1 "test_lp"
    CHECK_RESULT $? 0 0 "Failed option: --name-prefix"
    fi

    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    cd .. && rm -rf ./tmp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"