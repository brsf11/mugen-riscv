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
    DNF_INSTALL "p7zip tar"
    # create test files
    echo 1 > file1
    echo 2 > file2
    # Additional archive used by test -ax
    7za a archive_extendd.tar file1
    7za a archive_extendd.7z file2
    # need to disable ! style history substitution.
    set +H
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # test 7za Switches
    # -- : Stop switches parsing
    7za a archive.7z -- -stxtar file1 2>&1 | grep -Poz "WARNING: No more files\n-stxtar"
    CHECK_RESULT $? 0 0 "test failed with --"
    # -ai[r[-|0]]{@listfile|!wildcard} : Include archives
    # list file in *.tar *.7z
    7za l -air0!*.7z *.tar | grep -E '.*3 files'
    CHECK_RESULT $? 0 0 "test failed with -ai"
    # -ax eXclude archives
    # list file in *.7z but exclude archive.7z
    7za l -air0!*.7z -ax!archive.7z archive.7z | grep -Poz '.*file2\n.*\n.*1 files'
    CHECK_RESULT $? 0 0 "test failed with -ax"
    # -ao Overwrite mode
    # extracts all files from archive.7z archive and overwrites existing files
    7za x archive.7z -aoa && grep '1' file1
    CHECK_RESULT $? 0 0 "test failed with -ao"
    # -an Disable parsing of archive_name
    # list file in *.7z but exclude archive.7z
    7za l -an -air0!*.7z -ax!archive.7z | grep -Poz '.*file2\n.*\n.*1 files'
    CHECK_RESULT $? 0 0 "test failed with -an"
    # -bb
    # set output log level 3 when add file2 to archive.7z
    7za a -bb3 archive.7z file2 | grep -E '^=\s.*|U\s.*'
    CHECK_RESULT $? 0 0 "test failed with -bb"
    # -bd disable progress indicator
    7za a -bd archive.7z file2 | grep 'Everything is Ok'
    CHECK_RESULT $? 0 0 "test failed with -bd"
    # -bs set output stream for output/error/progress line
    7za a -bse1 | grep 'Command Line Error:'$'\n''Cannot find archive name'
    CHECK_RESULT $? 0 0 "test failed with -bs"
    # -bt show execution time statistics
    7za a -bt archive7.7z file1 | grep 'Everything is Ok'
    CHECK_RESULT $? 0 0 "test failed with -bt"
    # -i Include filenames
    7za a -ir0!file* archive8.7z && 7za l archive8.7z | grep -Poz '.*file1\n.*file2\n.*\n.*2 files'
    CHECK_RESULT $? 0 0 "test failed with -i"
    # -m set compression Method
    # x in mx means set no compression.
    7za a -mx0 archive9.tar file2 && tar -tvf archive9.tar | grep '.*file2'
    CHECK_RESULT $? 0 0 "test failed with -m"
    # -mmt[N] set number of CPU threads
    7za a -mmt1 archive.7z file2
    CHECK_RESULT $? 0 0 "test failed with -mmt" | grep 'Everything is Ok'
    # -o set Output directory
    7za x -otmp archive.7z file2 && grep 2 tmp/file2
    CHECK_RESULT $? 0 0 "test failed with -o"
    # -p set Password
    7za a archive_passwd.7z -p123456 file1 && 7za l archive_passwd.7z | grep -Poz '.*file1\n.*\n.*1 files' && 7za x -aoa archive_passwd.7z -p123456
    CHECK_RESULT $? 0 0 "test failed with -p"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    set -H
    rm -rf tmp file* archive*
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
