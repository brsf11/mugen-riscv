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

    byacc -h 2>&1 | grep 'Usage: byacc'
    CHECK_RESULT $? 0 0 "Failed option: -h"
    byacc --help 2>&1 | grep 'Usage: byacc'
    CHECK_RESULT $? 0 0 "Failed option: --help"

    byacc --file-prefix ./tmp/test_lb ./common/test.y 
    test -f ./tmp/test_lb.tab.c
    CHECK_RESULT $? 0 0 "Failed option: --file-prefix"

    byacc -b ./tmp/test_lh --defines ./tmp/test_lh.c ./common/test.y -o ./tmp/test_lh.c
    test -f ./tmp/test_lh.c 
    CHECK_RESULT $? 0 0 "Failed option: --defines"

    byacc ./common/test.y --output ./tmp/test_lo.tab.c
    test -f ./tmp/test_lo.tab.c
    CHECK_RESULT $? 0 0 "Failed option: --output"
    
    byacc -b ./tmp/test_lg --graph ./common/test.y -o ./tmp/test_lg.dot
    test -f ./tmp/test_lg.dot
    CHECK_RESULT $? 0 0 "Failed option: --graph"

    byacc --name-prefix test_lp ./common/test.y -o ./tmp/test_lp.tab.c
    cat ./tmp/test_lp.tab.c | grep -m 1 "test_lp"
    CHECK_RESULT $? 0 0 "Failed option: --name-prefix"

    LOG_INFO "Finish test!"

}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf ./tmp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"