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
	pkg_name=$(dnf list | head -n 3 | tail -n 1 | awk '{print $1}')
	yumdownloader ${pkg_name}
	test -d ~/rpmbuild && rm -rf ~/rpmbuild && LOG_INFO "Successfully deleted this dir."
	LOG_INFO "End of environmental preparation."
}

function run_test() {
	LOG_INFO "Start testing"

	rpmdev-rmdevelrpms -h
	CHECK_RESULT $? 0 0 "Failed option: -h"
	rpmdev-rmdevelrpms -v | grep 'version'
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

	rpmdev-sha1 *rpm
	CHECK_RESULT $? 0 0 "Failed command: rpmdev-sha1"

	rpmdev-sha224 *rpm
	CHECK_RESULT $? 0 0 "Failed command: rpmdev-sha224"

	rpmdev-sha256 *rpm
	CHECK_RESULT $? 0 0 "Failed command: rpmdev-sha256"

	rpmdev-sha384 *rpm
	CHECK_RESULT $? 0 0 "Failed command: rpmdev-sha384"

	rpmdev-sha512 *rpm
	CHECK_RESULT $? 0 0 "Failed command: rpmdev-sha512"

	var1="$(ls *rpm | rpmdev-sort | wc -l)"
	[ "$var1" == 1 ]
	CHECK_RESULT $? 0 0 "Failed command: rpmdev-sort"
	rpmdev-sort -h
	CHECK_RESULT $? 0 0 "Failed option: rpmdev-sort -h"

	rpmdev-sum *rpm
	CHECK_RESULT $? 0 0 "Failed command: rpmdev-sum"

	LOG_INFO "End to run test."

}

function post_test() {
	LOG_INFO "Start to restore the test environment."
	DNF_REMOVE
	rm -rf ~/rpmbuild
	rm *rpm
	LOG_INFO "End to restore the test environment."
}

main "$@"
