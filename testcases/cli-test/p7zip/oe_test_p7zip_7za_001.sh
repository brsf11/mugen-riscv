#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   blackgaryc
# @Contact   :   blackgaryc@gmail.com
# @Date      :   2022/06/08
# @License   :   Mulan PSL v2
# @Desc      :   Test p7zip
# #############################################

source "${OET_PATH}/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL 'p7zip tar'
    echo 1 > file1
    echo 2 > file2
    mkdir tmp
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # test --help
    7za --help | grep "Usage: 7za"
    CHECK_RESULT $? 0 0 "test failed with --help"
    # test 7za Function Letters
    # a Add
    7za a archive.tar file1 file2 && tar -df archive.tar file1 file2 | grep -v 'Mode differs'
    CHECK_RESULT $? 1 0 "test failed with a"
    # b Benchmark
    7za b 1 | grep -E '(Avr|Tot).*'
    CHECK_RESULT $? 0 0 "test failed with b"
    # l List
    7za l archive.tar | grep -E '.*file1'$'\n''.*file2'
    CHECK_RESULT $? 0 0 "test failed with l"
    # d Delete
    7za d archive.tar file1 && tar -tvf archive.tar | grep '.*file1'
    CHECK_RESULT $? 1 0 "test failed with d"
    # e Extract
    7za e archive.tar tmp/ && grep '2' file2
    CHECK_RESULT $? 0 0 "test failed with e"
    # h Calculate hash
    7za h file1 | grep 'CRC32  for data:.*'
    CHECK_RESULT $? 0 0 "test failed with h"
    # i Show information about supported formats
    7za i | grep -Pzo '(Formats|Codecs|Hashers):\n(\s*\S*)*'
    CHECK_RESULT $? 0 0 "test failed with i"
    # rn Rename
    7za rn archive.tar file2 file3 && tar -tvf archive.tar | grep -E '\-.*file3'
    CHECK_RESULT $? 0 0 "test failed with rn"
    # t Test
    7za t archive.tar | grep -Ez 'Testing archive: archive.tar.*Everything is Ok'
    CHECK_RESULT $? 0 0 "test failed with t"
    # u Update
    echo update >>file1
    7za u archive.tar file1 && tar -df archive.tar file1 | grep -v 'Mode differs'
    CHECK_RESULT $? 1 0 "test failed with u"
    # x eXtract with full paths
    7za x archive.tar -otestfiles file1 && grep -Pzo '1\nupdate' testfiles/file1
    CHECK_RESULT $? 0 0 "test failed with x"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf file* testfiles archive.tar tmp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
