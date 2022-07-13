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
    # create test files
    echo 1 > file1
    echo 2 > file2
    echo -e "\u6d4b\u8bd5" > file_utf8
    7za a archive.tar file1 file2
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # test 7za Switches
    # -r disable recursion
    7za l archive.tar * -r- | grep -Poz '.*file1\n.*file2'
    CHECK_RESULT $? 0 0 "test failed with -r"
    # -sa
    7za a archive2.tar -saa file_utf8 && 7za l archive2.tar.7z | grep -Poz '.*file_utf8'
    CHECK_RESULT $? 0 0 "test failed with -sa"
    # -scc
    7za a archive3.tar -sccUTF-8 file_utf8 && rm -f file_utf8 && 7za x archive3.tar && file file_utf8 | grep -E "Unicode text|UTF-8"
    CHECK_RESULT $? 0 0 "test failed with -scc"
    # -scs
    7za a archive4.tar -scsUTF-8 file1 | grep 'Everything is Ok'
    CHECK_RESULT $? 0 0 "test failed with -scs"
    # -scrc
    7za h -scrcCRC32 file1 | grep 'CRC32  for data:.*'
    CHECK_RESULT $? 0 0 "test failed with -scrc"
    # -sdel
    7za a archive6.tar -sdel file1 && tar -tvf archive6.tar | grep '.*file1' && test -f file1
    CHECK_RESULT $? 1 0 "test failed with -sdel"
    # -seml
    7za a archive7.7z -seml file2 | grep 'Everything is Ok'
    CHECK_RESULT $? 0 0 "test failed with -seml"
    # -si
    echo stdin | 7za a archive.7z -sifile0 && 7za l archive.7z | grep '.*file0'
    CHECK_RESULT $? 0 0 "test failed with -si"
    # -slp
    7za a archive9.tar -slp file2 | grep 'Everything is Ok'
    CHECK_RESULT $? 0 0 "test failed with -slp"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf archive* file*
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
