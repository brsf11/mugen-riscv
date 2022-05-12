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
#@Date      	:   2022-4-6 9:52:00
#@License   	:   Mulan PSL v2
#@Desc      	:   test rpmdev-rmdevelrpms rpmdev-setuptree rpmdev-sha1 rpmdev-sha224 rpmdev-sha256 rpmdev-sha384 rpmdev-sha512 rpmdev-sort rpmdev-sum
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "rpmdevtools"
    pkg_name=$(dnf list | head -n 3 | tail -n 1 | awk '{print $1}' | awk 'BEGIN {FS="."} {print $1}')
    yumdownloader ${pkg_name}
    test -d ~/rpmbuild && rm -rf ~/rpmbuild && LOG_INFO "Successfully deleted this dir."
    LOG_INFO "End of environmental preparation."
}

function run_test() {
    LOG_INFO "Start to run test."

    rpmdev-rmdevelrpms -h | grep -A 30 "rpmdev-rmdevelrpms" | grep "Options:"
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmdev-rmdevelrpms -v | grep 'rpmdev-rmdevelrpms version'
    CHECK_RESULT $? 0 0 "Failed option: -v"
    rpmdev-rmdevelrpms -l | grep -E 'devel|debuginfo|sdk|static|perl'
    CHECK_RESULT $? 0 0 "Fail option: -l"
    rpmdev-rmdevelrpms --qf test | grep 'Not removed due to dependencies'
    CHECK_RESULT $? 0 0 "Fail option: --qf"
    rpmdev-rmdevelrpms -y | grep 'Not removed due to dependencies'
    CHECK_RESULT $? 0 0 "Fail option: -y"

    rpmdev-setuptree
    test -d ~/rpmbuild
    CHECK_RESULT $? 0 0 "Failed command: rpmdev-setuptree"

    sha1=$(rpmdev-sha1 ${pkg_name}*rpm | head -n 1 | awk '{print $1}')
    sha1_num=$(expr length ${sha1})
    test ${sha1_num} == 40
    CHECK_RESULT $? 0 0 "Failed command: rpmdev-sha1"

    sha224=$(rpmdev-sha224 ${pkg_name}*rpm | head -n 1 | awk '{print $1}')
    sha224_num=$(expr length ${sha224})
    test ${sha224_num} == 56
    CHECK_RESULT $? 0 0 "Failed command: rpmdev-sha224"

    sha256=$(rpmdev-sha256 ${pkg_name}*rpm | head -n 1 | awk '{print $1}')
    sha256_num=$(expr length ${sha256})
    test ${sha256_num} == 64
    CHECK_RESULT $? 0 0 "Failed command: rpmdev-sha256"

    sha384=$(rpmdev-sha384 ${pkg_name}*rpm | head -n 1 | awk '{print $1}')
    sha384_num=$(expr length ${sha384})
    test ${sha384_num} == 96
    CHECK_RESULT $? 0 0 "Failed command: rpmdev-sha384"

    sha512=$(rpmdev-sha512 ${pkg_name}*rpm | head -n 1 | awk '{print $1}')
    sha512_num=$(expr length ${sha512})
    test ${sha512_num} == 128
    CHECK_RESULT $? 0 0 "Failed command: rpmdev-sha512"

    CHECK_RESULT $(ls *rpm | rpmdev-sort | wc -l) 1 0 "Failed command: rpmdev-sort"
    rpmdev-sort -h | grep -A 4 "rpmdev-sort" | grep "Supported formats:"
    CHECK_RESULT $? 0 0 "Failed option: rpmdev-sort -h"

    rpmdev-sum ${pkg_name}*rpm | grep "${pkg_name}"
    CHECK_RESULT $? 0 0 "Failed command: rpmdev-sum"

    LOG_INFO "End to run test."

}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -rf ~/rpmbuild *rpm
    LOG_INFO "End to restore the test environment."
}

main "$@"
