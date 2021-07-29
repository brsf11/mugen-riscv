#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/19
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of phar and phar.phar command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL php-cli
    sed -i 's/;phar.readonly = On/phar.readonly = Off/g' /etc/php.ini || exit 1
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    php ../common/testBuild.php
    CHECK_RESULT $?
    test -f test.phar
    CHECK_RESULT $?
    phar help | grep "/usr/bin/phar <command> \[options\]"
    CHECK_RESULT $?
    phar help-list | grep "add compress delete extract help help-list info list meta-del meta-get meta-set pack sign stub-get stub-set tree version"
    CHECK_RESULT $?
    phar version | grep -i "version"
    CHECK_RESULT $?

    phar add -f test.phar ../common/project/ | grep -E "lib/lib_a.php|template/msg.html|Lib.php|file/test.css|file/test.js|index.php"
    CHECK_RESULT $?
    phar add -f test.phar -a tt.phar ../common/project/
    CHECK_RESULT $?
    phar info -f test.phar | grep "Uncompressed-files: 6"
    CHECK_RESULT $?
    phar add -f test.phar -c gz ../common/project/
    CHECK_RESULT $?
    phar info -f test.phar | grep 'Compressed-gz.*6'
    CHECK_RESULT $?
    phar add -f test.phar -i .php ../common/project/ | grep ".php"
    CHECK_RESULT $?
    phar add -f test.phar -l 1 ../common/project/ | grep -E "lib_a.php|msg.html|Lib.php|test.css|test.js|index.php"
    CHECK_RESULT $?
    phar add -f test.phar -x .php ../common/project/ | grep ".php"
    CHECK_RESULT $? 1

    phar info -f test.phar | grep "Uncompressed-files: 10"
    CHECK_RESULT $?
    phar compress -f test.phar -c bz2
    CHECK_RESULT $?
    phar info -f test.phar | grep "Compressed-bz2.*10"
    CHECK_RESULT $?
    phar compress -f test.phar -c bz2 -e lib/lib_a.php
    CHECK_RESULT $?

    b_count=$(phar list -f test.phar | wc -l)
    phar delete -f test.phar -e lib_a.php
    CHECK_RESULT $?
    a_count=$(phar list -f test.phar | wc -l)
    test $b_count -eq $a_count
    CHECK_RESULT $? 1
    phar list -f test.phar | grep "test.phar/lib_a.php"
    CHECK_RESULT $? 1

    phar extract -f test.phar test1/ | grep "ok"
    CHECK_RESULT $?
    test -d test1
    CHECK_RESULT $?
    phar extract -f test.phar -i .css test2/ | grep "ok"
    CHECK_RESULT $?
    test -d test2
    CHECK_RESULT $?
    phar extract -f test.phar -x .css test3/ | grep "ok"
    CHECK_RESULT $?
    test -d test3
    CHECK_RESULT $?

    phar info -f test.phar | grep -E "Alias|Hash-type|Hash|Entries|Uncompressed-files|Compressed-files|Compressed-gz|Compressed-bz2|Uncompressed-size|Compressed-size|Compression-ratio|Metadata-global|Metadata-files|Stub-size"
    CHECK_RESULT $?
    phar info -f test.phar -k 3
    CHECK_RESULT $? 1

    phar list -f test.phar | grep "phar:"
    CHECK_RESULT $?
    phar list -f test.phar -i lib | grep "lib"
    CHECK_RESULT $?
    phar list -f test.phar -x .css | grep ".css"
    CHECK_RESULT $? 1

    phar meta-del -f test.phar
    CHECK_RESULT $?
    phar meta-del -f test.phar -k 3
    CHECK_RESULT $? 1
    phar meta-del -f test.phar -e /lib/lib_a.php
    CHECK_RESULT $?

    phar meta-get -f test.phar | grep "No Metadata"
    CHECK_RESULT $?
    phar meta-get -f test.phar -k 2 | grep "No Metadata"
    CHECK_RESULT $?
    phar meta-get -f test.phar -e /lib/lib_a.php | grep "No Metadata"
    CHECK_RESULT $?

    phar pack -f test.phar test1/
    CHECK_RESULT $?
    phar pack -f test.phar -b dd test1/
    CHECK_RESULT $?
    phar info -f test.phar | grep "Uncompressed-files: 9"
    CHECK_RESULT $?
    phar pack -f test.phar -c gz test1/
    CHECK_RESULT $?
    phar info -f test.phar | grep "Compressed-gz.*9"
    CHECK_RESULT $?
    phar pack -f test.phar -h md5 test1/
    CHECK_RESULT $?
    phar info -f test.phar | grep "MD5"
    CHECK_RESULT $?
    phar pack -f test.phar -i .php test1/ | grep ".php"
    CHECK_RESULT $?
    phar pack -f test.phar -l 1 test1/
    CHECK_RESULT $?
    phar pack -f test.phar -p 0 test1/
    CHECK_RESULT $?
    phar pack -f test.phar -x .css test1/ | grep ".css"
    CHECK_RESULT $? 1

    phar tree -f test.phar | grep -E "file|lib|template"
    CHECK_RESULT $?
    phar tree -f test.phar -i lib | grep "lib"
    CHECK_RESULT $?
    phar tree -f test.phar -x file | grep "file"
    CHECK_RESULT $? 1

    phar sign -f test.phar -h sha512
    CHECK_RESULT $?
    phar info -f test.phar | grep "SHA-512"
    CHECK_RESULT $?
    openssl genrsa -out ca.key 1024
    CHECK_RESULT $?
    test -f ca.key
    CHECK_RESULT $?
    phar sign -f test.phar -h openssl -y ca.key
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    sed -i 's/phar.readonly = Off/;phar.readonly = On/g' /etc/php.ini
    rm -rf $(ls | grep -v ".sh")
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main $@