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

    pngcrush -huffman ./common/test.png ./tmp/test_huffman.png 2>&1 | grep "Ignoring invalid option: -huffman"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -huffman"
    test -f ./tmp/test_huffman.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -huffman"

    pngcrush -keep dSIG ./common/test.png ./tmp/test_keep.png 2>&1 | grep "Ignoring invalid option: -keep"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -keep"
    test -f ./tmp/test_keep.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -keep"

    pngcrush -l 1 ./common/test.png ./tmp/test_l.png 2>&1 | grep "Ignoring invalid option: -l"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -l"
    test -f ./tmp/test_l.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -l"

    pngcrush -m 1 ./common/test.png ./tmp/test_m.png 2>&1 | grep "Ignoring invalid option: -m"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -m"
    test -f ./tmp/test_m.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -m"

    pngcrush -max 524288 ./common/test.png ./tmp/test_max.png 2>&1 | grep "Ignoring invalid option: -max"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -max"
    test -f ./tmp/test_max.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -max"

    pngcrush -n ./common/test.png 2>&1 | grep "Ignoring invalid option: -n"
    CHECK_RESULT $? 0 1"Failed to run command: pngcrush -n"

    pngcrush -new ./common/test.png ./tmp/test_new.png 2>&1 | grep "Ignoring invalid option: -new"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -new"
    test -f ./tmp/test_new.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -new"

    pngcrush -newtimestamp ./common/test.png ./tmp/test_newtimestamp.png 2>&1 | grep "Ignoring invalid option: -newtimestamp"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -newtimestamp"
    test -f ./tmp/test_newtimestamp.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -newtimestamp"

    pngcrush -nobail ./common/test.png ./tmp/test_nobail.png 2>&1 | grep "Ignoring invalid option: -nobail"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -nobail"
    test -f ./tmp/test_nobail.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -nobail"

    pngcrush -nocheck ./common/test.png ./tmp/test_nocheck.png 2>&1 | grep "Ignoring invalid option: -nocheck"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -nocheck"
    test -f ./tmp/test_nocheck.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -nocheck"

    pngcrush -nofilecheck ./common/test.png ./tmp/test_nofilecheck.png 2>&1 | grep "Ignoring invalid option: -nofilecheck"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -nofilecheck"
    test -f ./tmp/test_nofilecheck.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -nofilecheck"

    pngcrush -noforce ./common/test.png ./tmp/test_noforce.png 2>&1 | grep "Ignoring invalid option: -noforce"
    CHECK_RESULT $? 0 1 "Failed to run command: pngcrush -noforce"
    test -f ./tmp/test_noforce.png
    CHECK_RESULT $? 0 0 "Failed to run command: pngcrush -noforce"

    LOG_INFO "Finish test!"

}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf ./tmp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"