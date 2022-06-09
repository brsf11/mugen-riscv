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
    # dir used by -w
    mkdir tmp
    tar -cf archive.tar file1 file2
    cp archive.tar archive4.7z
    set +H
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # test 7za Switches
    # -ssw : compress shared files
    7za a archive1.tar -ssw file1 file2 && tar -tvf archive.tar | grep -Pzo '.*file1\n.*file2'
    CHECK_RESULT $? 0 0 "test failed with -ssw"
    # -stl : set archive timestamp from the most recently modified file
    7za a archive2.tar -stl file1 file2 && test `stat --format="%Y" archive2.tar` -eq `stat --format="%Y" file2`
    CHECK_RESULT $? 0 0 "test failed with -stl"
    # -stm{HexMask} : set CPU thread affinity mask (hexadecimal number)
    7za a archive3.tar -stm1 file1 file2 && tar -tvf archive.tar | grep -Pzo '.*file1\n.*file2'
    CHECK_RESULT $? 0 0 "test failed with -stm"
    # -stx{Type} : exclude archive type
    7za l archive4.7z -stx7z | grep -Poz '.*file1\n.*file2'
    CHECK_RESULT $? 0 0 "test failed with -stx"
    # -t{Type} : Set type of archive
    7za a archive5.7z -t7z file1 && tar -df archive.tar file1 | grep -v 'Mode differs'
    CHECK_RESULT $? 1 0 "test failed with -t"
    # -u[-][p#][q#][r#][x#][y#][z#][!newArchiveName] : Update options
    # z0 means if file in archive is same as the file on disk, then ignore
    7za a archive.tar -uz0 file1 | grep 'Files read from disk: 0'
    CHECK_RESULT $? 0 0 "test failed with -u"
    # -v{Size}[b|k|m|g] : Create volumes
    7za a archive7.7z file1 file2 -v1k && 7za l archive7.7z.001 | grep -Poz '.*file1\n.*file2'
    CHECK_RESULT $? 0 0 "test failed with -v"
    # -w[{path}] : assign Work directory. Empty path means a temporary dire
    7za a archive8.tar -wtmp file1 && tar -df archive8.tar file1 | grep -v 'Mode differs'
    CHECK_RESULT $? 1 0 "test failed with -w"
    # -x[r[-|0]]{@listfile|!wildcard} : eXclude filenames
    7za a archive9.tar -xr-!file1 file* && tar -tvf archive9.tar | grep -v '.*file2'
    CHECK_RESULT $? 1 0 "test failed with -x"
    # -y : assume Yes on all queries
    # Overwrite file1 file2
    7za x archive.tar -y | grep 'Everything is Ok'
    CHECK_RESULT $? 0 0 "test failed with -y"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf file* archive* tmp
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
