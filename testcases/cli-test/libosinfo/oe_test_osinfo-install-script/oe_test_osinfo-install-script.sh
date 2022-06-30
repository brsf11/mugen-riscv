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
# @Date      :   2020/10/29
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of osinfo-install-script command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL libosinfo
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    osinfo-install-script --help | grep -E "Usage:|osinfo-install-script \[OPTION…\]"
    CHECK_RESULT $?
    osinfo-install-script --profile jeos --config l10n-timezone=GMT --config l10n-keyboard=uk --config l10n-language=en_GB --config admin-password=123456 --config user-login=berrange --config user-password=123456 --config user-realname="Daniel P Berrange" fedora16
    CHECK_RESULT $?
    test -f fedora.ks && rm -rf fedora.ks
    CHECK_RESULT $?
    mkdir testdir
    CHECK_RESULT $?
    osinfo-install-script --profile jeos --config l10n-timezone=GMT --config l10n-keyboard=uk --config l10n-language=en_GB --config admin-password=123456 --config user-login=berrange --config user-password=123456 --config user-realname="Daniel P Berrange" fedora16 --output-dir testdir/
    CHECK_RESULT $?
    test -f testdir/fedora.ks
    CHECK_RESULT $?
    osinfo-install-script --profile jeos --config l10n-timezone=GMT --config l10n-keyboard=uk --config l10n-language=en_GB --config admin-password=123456 --config user-login=berrange --config user-password=123456 --config user-realname="Daniel P Berrange" fedora16 -q
    CHECK_RESULT $?
    test -f fedora.ks
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    roc=$(ls | grep -v ".sh")
    rm -rf $roc
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
