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
#@Desc      	:   test rpmargs rpmdev-bumpspec rpmdev-checksig rpmdev-cksum rpmdev-diff rpmdev-extract rpmdev-md5 rpmdev-newinit rpmdev-newspec rpmdev-packager
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test(){
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "rpmdevtools"
    pkg_name=$(dnf list | head -n 3 | tail -n 1 | awk '{print $1}')
    yumdownloader ${pkg_name}
    mkdir -p /ALT/Sisyphus/files/i586/RPMS
    mkdir -p /ALT/Sisyphus/files/noarch/RPMS
    mkdir -p /ALT/Sisyphus/files/SRPMS
    wget https://repo.openeuler.org/openEuler-21.09/source/Packages/nodejsporter-1.0-2.oe1.src.rpm
    mv *src.rpm /ALT/Sisyphus/files/SRPMS/
    cp *rpm /ALT/Sisyphus/files/i586/RPMS/
    cp *rpm /ALT/Sisyphus/files/noarch/RPMS

    wget https://gitee.com/src-openeuler/rootsh/raw/master/rootsh.spec
    echo "test -f." > file1

    pkg_name1=$(dnf list | head -n 4 | tail -n 1 | awk '{print $1}')
    mkdir ./tmp_dir
    yumdownloader --destdir=./tmp_dir ${pkg_name1}

    LOG_INFO "End of environmental preparation."
}

function run_test(){
	LOG_INFO "Start testing."

	rpmargs -h 
	CHECK_RESULT $? 0 0 "Failed option: -h"
	rpmargs -c file -a | grep "RPM"
	CHECK_RESULT $? 0 0 "Failed option: -a"
	rpmargs -c file -p /ALT/Sisyphus/files/noarch/RPMS/*rpm
	CHECK_RESULT $? 0 0 "Failed option: -p"	

	rpmdev-bumpspec -h
	CHECK_RESULT $? 0 0 "Failed option: -h"
	rpmdev-bumpspec -c "test1" rootsh.spec
	cat rootsh.spec | grep 'test1'
	CHECK_RESULT $? 0 0 "Failed option: -c"
	rpmdev-bumpspec -V rootsh.spec | grep '[-+]'
	CHECK_RESULT $? 0 0 "Failed option: -V"
	rpmdev-bumpspec -v
	CHECK_RESULT $? 0 0 "Failed option: -v"	
	rpmdev-bumpspec -u test_name\ xxxxxxxxxx@qq.com rootsh.spec
	cat rootsh.spec | grep 'test_name'
	CHECK_RESULT $? 0 0 "Failed option: -u"
	rpmdev-bumpspec -f file1 rootsh.spec
	cat rootsh.spec | grep '^-\ test\ -f.'
	CHECK_RESULT $? 0 0 "Failed option: -f"
	rpmdev-bumpspec -r rootsh.spec
	CHECK_RESULT $? 0 0 "Failed option: -r"
	rpmdev-bumpspec -s release rootsh.spec
	CHECK_RESULT $? 0 0 "Failed option: -s"
	rpmdev-bumpspec -n new_test rootsh.spec
	CHECK_RESULT $? 0 0 "Failed option: -n"

	rpmdev-checksig *rpm | grep 'SHA1'
	CHECK_RESULT $? 0 0 "Failed command:rpmdev-checksig"

	rpmdev-cksum *rpm
	CHECK_RESULT $? 0 0 "Failed command: rpmdev-cksum"

	rpmdev-diff -v
	CHECK_RESULT $? 0 0 "Failed option: -v"
	rpmdev-diff -h
	CHECK_RESULT $? 0 0 "Failed option: -h"
	rpmdev-diff -c ./*rpm ./tmp_dir/*rpm
	CHECK_RESULT $? 0 0 "Failed option: -c"
	rpmdev-diff -l ./*rpm ./tmp_dir/*rpm
	CHECK_RESULT $? 0 0 "Failed option: -l"
	rpmdev-diff -L ./*rpm ./tmp_dir/*rpm
	CHECK_RESULT $? 0 0 "Failed option: -L"
	rpmdev-diff -m ./*rpm ./tmp_dir/*rpm
	CHECK_RESULT $? 0 0 "Failed option: -m"
	rpmdev-diff -c -y ./*rpm ./tmp_dir/*rpm
	CHECK_RESULT $? 0 0 "Failed option: -y"

	rpmdev-extract -q ./*rpm
	CHECK_RESULT $? 0 0 "Failed option: -q"
	rpmdev-extract -f ./*rpm
	CHECK_RESULT $? 0 0 "Failed option: -f"	
	rpmdev-extract -C ./tmp_dir ./*rpm
	CHECK_RESULT $? 0 0 "Failed option: -C"
	rpmdev-extract -h 
	CHECK_RESULT $? 0 0 "Failed option: -h"
	rpmdev-extract -v
	CHECK_RESULT $? 0 0 "Failed option: -v"

	rpmdev-md5 *rpm
	CHECK_RESULT $? 0 0 "Failed command: rpmdev-md5"

	rpmdev-newinit -v 
	CHECK_RESULT $? 0 0 "Failed options: -v"
	rpmdev-newinit -h
	CHECK_RESULT $? 0 0 "Failed options: -h"
	rpmdev-newinit -o test.init
	test -f ./test.init 
	CHECK_RESULT $? 0 0 "Failted options: -o"

	rpmdev-newspec -o testo.spec
	test -f testo.spec
	CHECK_RESULT $? 0 0 "Failed option: -o"
	rpmdev-newspec -t python -o testt.spec
	cat testt.spec | grep 'python'
	CHECK_RESULT $? 0 0 "Failed option: -t"
	rpmdev-newspec -m -o testm.spec
	cat testm.spec | grep '%{buildroot}'
	CHECK_RESULT $? 0 0 "Failed option: -m"
	rpmdev-newspec -r 4.3 -o testr.spec | grep '4.3'
	CHECK_RESULT $? 0 0 "Failed option: -r"
	rpmdev-newspec -h
	CHECK_RESULT $? 0 0 "Failed option: -h"
	rpmdev-newspec -v 
	CHECK_RESULT $? 0 0 "Failed option: -v"

	rpmdev-packager
	CHECK_RESULT $? 0 0 "Failed command: rpmdev-packager"

	LOG_INFO "End to run test."
}

function post_test(){
	LOG_INFO "Start to restore the test environment."
	DNF_REMOVE
	rm rootsh.spec
	rm file1
	rm -rf /ALT
	rm *rpm
	rm -rf ./tmp_dir
	rm ./test.init
	rm ./test[otmr].spec
	rm -f ./test[otmr].spec
	rm -rf *x86_64
	LOG_INFO "End to restore the test environment."
}

main "$@"




