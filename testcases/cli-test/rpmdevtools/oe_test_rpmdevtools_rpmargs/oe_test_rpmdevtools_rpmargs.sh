#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   caimingxiang
#@Contact   	:   mingxiang@isrc.iscas.ac.cn
#@Date      	:   2022-3-18 19:37:00
#@License   	:   Mulan PSL v2
#@Desc      	:   test rpmargs rpmdev-checksig rpmdev-cksum rpmdev-diff rpmdev-extract rpmdev-md5
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "rpmdevtools"
    pkg_name=$(dnf list | head -n 3 | tail -n 1 | awk '{print $1}' | awk 'BEGIN {FS="."} {print $1}')
    pkg_arch=$(dnf list | head -n 3 | tail -n 1 | awk '{print $1}' | awk 'BEGIN {FS="."} {print $2}')
    yumdownloader ${pkg_name}
    mkdir -p /ALT/Sisyphus/files/i586/RPMS
    mkdir -p /ALT/Sisyphus/files/noarch/RPMS
    mkdir -p /ALT/Sisyphus/files/SRPMS
    cp ${pkg_name}*.rpm /ALT/Sisyphus/files/SRPMS/
    cp ${pkg_name}*.rpm /ALT/Sisyphus/files/i586/RPMS/
    cp ${pkg_name}*.rpm /ALT/Sisyphus/files/noarch/RPMS

    pkg_name1=$(dnf list | head -n 4 | tail -n 1 | awk '{print $1}' | awk 'BEGIN {FS="."} {print $1}')
    mkdir ./tmp_dir
    yumdownloader ${pkg_name1}

    LOG_INFO "End of environmental preparation."
}

function run_test() {
    LOG_INFO "Start to run test."

    rpmargs -h | grep Usage:$'\n'"  "rpmargs
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmargs -c file -a | grep "${pkg_name}"
    CHECK_RESULT $? 0 0 "Failed option: -a"
    rpmargs -c file -p /ALT/Sisyphus/files/noarch/RPMS/${pkg_name}*.rpm | grep "${pkg_name}"
    CHECK_RESULT $? 0 0 "Failed option: -p"

    rpmdev-checksig ${pkg_name}*.rpm | grep "${pkg_name}.*.rpm: RSA/SHA1"
    CHECK_RESULT $? 0 0 "Failed command:rpmdev-checksig"

    rpmdev-cksum ${pkg_name}*rpm | head -n 1 | awk '{print $3}' | grep "${pkg_name}.*rpm"
    CHECK_RESULT $? 0 0 "Failed command: rpmdev-cksum"

    rpmdev-diff -v | grep 'rpmdev-diff version'
    CHECK_RESULT $? 0 0 "Failed option: -v"
    rpmdev-diff -h | grep -A 5 "rpmdev-diff" | grep "Options:"
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmdev-diff -c ${pkg_name}*.rpm ${pkg_name1}*.rpm
    CHECK_RESULT $? 0 0 "Failed option: -c"
    rpmdev-diff -l ${pkg_name}*.rpm ${pkg_name1}*.rpm
    CHECK_RESULT $? 0 0 "Failed option: -l"
    rpmdev-diff -L ${pkg_name}*.rpm ${pkg_name1}*.rpm
    CHECK_RESULT $? 0 0 "Failed option: -L"
    rpmdev-diff -m ${pkg_name}*.rpm ${pkg_name1}*.rpm
    CHECK_RESULT $? 0 0 "Failed option: -m"
    rpmdev-diff -c -y ${pkg_name}*.rpm ${pkg_name1}*.rpm
    CHECK_RESULT $? 0 0 "Failed option: -y"

    rpmdev-extract -q ${pkg_name}*.rpm
    test -d ${pkg_name}*${pkg_arch}
    CHECK_RESULT $? 0 0 "Failed option: -q"
    rpmdev-extract -f ${pkg_name}*.rpm | grep ${pkg_name}
    CHECK_RESULT $? 0 0 "Failed option: -f"
    rpmdev-extract -C ./tmp_dir ${pkg_name}*.rpm
    test -d ./tmp_dir/${pkg_name}*${pkg_arch}
    CHECK_RESULT $? 0 0 "Failed option: -C"
    rpmdev-extract -h | grep -A 10 "rpmdev-extract" | grep "Options:"
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmdev-extract -v | grep 'rpmdev-extract version'
    CHECK_RESULT $? 0 0 "Failed option: -v"

    rpmdev-md5 ${pkg_name}*rpm | head -n 1 | awk '{print $2}' | grep "${pkg_name}.*rpm"
    CHECK_RESULT $? 0 0 "Failed command: rpmdev-md5"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf /ALT ./tmp_dir ${pkg_name}* ${pkg_name1}*
    LOG_INFO "End to restore the test environment."
}

main "$@"
