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
# @Desc      	:   the test of pngcrush package
####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL pngcrush
    test -d tmp || mkdir tmp
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."

    pngcrush -nolimits ./common/test.png ./tmp/test_nolimits.png 2>&1 | grep "Ignoring invalid option: -nolimits"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -nolimits"
    test -f ./tmp/test_nolimits.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -nolimits"

    pngcrush -noreduce ./common/test.png ./tmp/test_noreduce.png 2>&1 | grep "Ignoring invalid option: -noreduce"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -noreduce"
    test -f ./tmp/test_noreduce.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -noreduce"

    pngcrush -noreduce_palette ./common/test.png ./tmp/test_noreduce_palette.png 2>&1 | grep "Ignoring invalid option: -noreduce_palette"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -noreduce_palette"
    test -f ./tmp/test_noreduce_palette.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -noreduce_palette"

    pngcrush -old ./common/test.png ./tmp/test_old.png 2>&1 | grep "Ignoring invalid option: -old"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -old"
    test -f ./tmp/test_old.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -old"

    pngcrush -oldtimestamp ./common/test.png ./tmp/test_oldtimestamp.png 2>&1 | grep "Ignoring invalid option: -oldtimestamp"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -oldtimestamp"
    test -f ./tmp/test_oldtimestamp.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -oldtimestamp"

    pngcrush -q ./common/test.png ./tmp/test_q.png 2>&1 | grep "Ignoring invalid option: -q"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -q"
    test -f ./tmp/test_q.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -q"

    pngcrush -reduce ./common/test.png ./tmp/test_reduce.png 2>&1 | grep "Ignoring invalid option: -reduce"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -reduce"
    test -f ./tmp/test_reduce.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -reduce"

    pngcrush -rem alla ./common/test.png ./tmp/test_rem.png 2>&1 | grep "Ignoring invalid option: -rem"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -rem"
    test -f ./tmp/test_rem.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -rem"

    pngcrush --replace_gamma 0.45455 ./common/test.png ./tmp/test_replace_gamma.png 2>&1 | grep "Ignoring invalid option: -replace_gamma"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -replace_gamma"
    test -f ./tmp/test_replace_gamma.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -replace_gamma"

    pngcrush --res 1 ./common/test.png ./tmp/test_res.png 2>&1 | grep "Ignoring invalid option: -res"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -res"
    test -f ./tmp/test_res.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -res" 

    pngcrush -rle ./common/test.png ./tmp/test_rle.png 2>&1 | grep "Ignoring invalid option: -rle"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -rle"
    test -f ./tmp/test_rle.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -rle" 

    pngcrush -s ./common/test.png ./tmp/test_s.png 2>&1 | grep "Ignoring invalid option: -s"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -s"
    test -f ./tmp/test_s.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -s" 

    LOG_INFO "Finish test!"

}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf ./tmp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"