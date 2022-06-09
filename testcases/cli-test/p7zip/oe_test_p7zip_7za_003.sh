#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# ##################################################################
# @Author    :   blackgaryc
# @Contact   :   blackgaryc@gmail.com
# @Date      :   2022/06/08
# @License   :   Mulan PSL v2
# @Desc      :   Test p7zip
# ##################################################################

source "${OET_PATH}/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL 'p7zip tar'
    # create test files
    echo 1 > file1
    echo 2 > file2
    echo 3 > filename_case_test
    echo 4 > Filename_Case_Test
    ln -sf $PWD/file1 $PWD/file1_link_s
    ln -f $PWD/file1 $PWD/file1_link_h
    mkdir tmp_empty_dir
    tar -cvf archive.tar file1 file2 tmp_empty_dir
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # test 7za Switches
    # -slt show technical information for l (List) command
    7za l -slt archive.tar | grep -E '(Path|Folder|Size|Packed Size|Modified|Mode|User|Group|Symbolic Link|Hard Link|Physical Size|Headers Size)\s=\s.*'
    CHECK_RESULT $? 0 0 "test failed with -slt"
    # -snh store hard links as links
    # WIM and TAR formats only
    7za a archive2.tar -snh file1 file1_link_h && tar -df archive2.tar file1 file1_link_h | grep -v 'Mode differs'
    CHECK_RESULT $? 1 0 "test failed with -snh"
    # -snl store symbolic links as links
    7za a archive3.tar -snl file file1_link_s && tar -df archive3.tar file1 file1_link_l | grep -v 'Mode differs'
    CHECK_RESULT $? 1 0 "test failed with -snl"
    # -so write data to stdout
    7za x archive.tar -so | tr -d '\n' | grep '12'
    CHECK_RESULT $? 0 0 "test failed with -so"
    # -spd disable wildcard matching for file names
    7za l -spd archive.tar 'file*' | grep -E '(file1|file2|file1_link_h|file1_link_s)'
    CHECK_RESULT $? 1 0 "test failed with -spd"
    # -spe eliminate duplication of root folder for extract command
    7za x -spe archive.tar tmp_empty_dir
    CHECK_RESULT $? 0 0 "test failed with -spe"
    # -spf use fully qualified file paths
    7za a archive7.7z -spf $PWD/file1 $PWD/file2 && 7za l archive7.7z | grep -Poz ".*$PWD/file1\n.*$PWD/file2"
    CHECK_RESULT $? 0 0 "test failed with -spf"
    # -ssc[-] set sensitive case mode
    7za a -ssc archive8.tar filename_case_test Filename_Case_Test && tar -tvf archive8.tar | grep -Poz ".*Filename_Case_Test\n.*filename_case_test"
    CHECK_RESULT $? 0 0 "test failed with -ssc"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf file* archive* tmp_* File*
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
