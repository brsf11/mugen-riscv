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
#@Date      	:   2022-3-8 20:50:00
#@License   	:   Mulan PSL v2
#@Desc      	:   test rpmdev-vercmp rpmdev-wipetree rpmelfsym rpmfile rpminfo rpmls rpmpeek rpmsodiff rpmsoname spectool
#####################################


source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test(){
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "rpmdevtools"
    useradd user_test
    su user_test -c "mkdir -p /home/user_test/rpmbuild/RPMS/x86_64"
    pkg_name=$(dnf list | head -n 3 | tail -n 1 | awk '{print$1}')
    yumdownloader ${pkg_name}
    chown user_test *rpm
    chmod 755 *rpm
    mv *rpm /home/user_test/rpmbuild/RPMS/x86_64

    yumdownloader ${pkg_name}
    mkdir -p /ALT/Sisyphus/files/i586/RPMS
    mkdir -p /ALT/Sisyphus/files/noarch/RPMS
    mkdir -p /ALT/Sisyphus/files/SRPMS
    wget https://repo.openeuler.org/openEuler-21.09/source/Packages/nodejsporter-1.0-2.oe1.src.rpm
    mv *src.rpm /ALT/Sisyphus/files/SRPMS/
    cp *rpm /ALT/Sisyphus/files/i586/RPMS/
    cp *rpm /ALT/Sisyphus/files/noarch/RPMS

    DNF_INSTALL "${pkg_name}"
    mkdir ./tmp_dir

    wget https://gitee.com/src-openeuler/rpmdevtools/raw/master/rpmdevtools.spec
    mkdir ./test_dir
    rpmdev-setuptree

    LOG_INFO "End of environmental preparation."
}


function run_test(){
    LOG_INFO "Start testing"

    rpmdev-vercmp 1 1 2 2 1 2
    CHECK_RESULT $? 12 0 "Failed option: n:n-n < n:n-n"
    rpmdev-vercmp 2 1 2 1 1 2
    CHECK_RESULT $? 11 0 "Failed option: n:n-n > n:n-n"
    rpmdev-vercmp 2 1
    CHECK_RESULT $? 11 0 "Failed option: n > n"
    rpmdev-vercmp 1 2
    CHECK_RESULT $? 12 0 "Failed option: n < n"
    rpmdev-vercmp 1 1
    CHECK_RESULT $? 0 0 "Failed option: n == n"
    rpmdev-vercmp 2 1 2 2 1 2
    CHECK_RESULT $? 0 0 "Failed option: n:n-n == n:n-n"
    rpmdev-vercmp -h
    CHECK_RESULT $? 0 0 "Failed option: -h"

    test -e /home/user_test/rpmbuild/RPMS/x86_64/*rpm 
    CHECK_RESULT $? 0 0 "Failed pre_test"
    su user_test -c "rpmdev-wipetree"
    test -e /home/user_test/rpmbuild/RPMS/x86_64/*rpm
    CHECK_RESULT $? 1 0 "Failed command: rpmdev-wipetree"

    rpmelfsym -p *rpm
    CHECK_RESULT $? 0 0 "Failed option: -p"
    rpmelfsym -h | grep 'Options:'
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmelfsym -a
    CHECK_RESULT $? 0 0 "Failed option: -a"

    rpmfile -p *rpm
    CHECK_RESULT $? 0 0 "Failed option: -p"
    rpmfile -h | grep 'Options:'
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmfile -a
    CHECK_RESULT $? 0 0 "Failed option: -a"

    rpminfo -h | grep 'Usage'
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpminfo -v *rpm 
    CHECK_RESULT $? 0 0 "Failed option: -v"
    rpminfo -q *rpm
    CHECK_RESULT $? 0 0 "Failed option: -q"
    rpminfo -qq *rpm
    CHECK_RESULT $? 0 0 "Failed option: -qq"
    rpminfo -i -o record
    test -e record
    CHECK_RESULT $? 0 0 'Failed option: -i -o'
    rpminfo -e *rpm 
    CHECK_RESULT $? 0 0 "Failed option: -e"
    rpminfo -l *rpm
    CHECK_RESULT $? 0 0 "Failed option: -l"
    rpminfo -p *rpm
    CHECK_RESULT $? 0 0 "Failed option: -p"
    rpminfo -np *rpm
    CHECK_RESULT $? 0 0 "Failed option: -np"
    rpminfo -nP *rpm
    CHECK_RESULT $? 0 0 "Failed option: -nP"
    rpminfo -r *rpm
    CHECK_RESULT $? 0 0 "Failed option: -r"
    rpminfo -ro *rpm
    CHECK_RESULT $? 0 0 "Failed option: -ro"
    rpminfo -s -o record1 *rpm
    test -e record1*
    CHECK_RESULT $? 0 0 "Failed option: -s "
    rpminfo -t *rpm
    CHECK_RESULT $? 0 0 "Failed option: -t"
    rpminfo -T ./tmp_dir *rpm

    rpmls -l *rpm

    rpmpeek -h | grep "Options:"
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmpeek *rpm ls -l | grep "usr"
    CHECK_RESULT $? 0 0 "Failed command: rpmpeek"
    rpmpeek -n attr*rpm ls -l 
    CHECK_RESULT $? 0 0 "Failed option: -n"

    rpmsodiff -h | grep "Usage:"	
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmsodiff *rpm *rpm
    CHECK_RESULT $? 0 0 "Failed command: rpmsodiff"

    rpmsoname -h | grep "Options:"
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmsoname -p *rpm | grep "/usr/lib64"
    CHECK_RESULT $? 0 0 "Failed option: -p"
    rpmsoname . | grep "/usr/lib64"
    CHECK_RESULT $? 0 0 "Failed command: rpmsoname"

    spectool -l rpmdevtools.spec | grep "Source"
    CHECK_RESULT $? 0 0 "Failed option: -l"
    spectool -g rpmdevtools.spec && test -e *tar.xz
    CHECK_RESULT $? 0 0 "Failed option: -g"
    spectool -h | grep "Options"
    CHECK_RESULT $? 0 0 "Failed option: -h"
    spectool -A rpmdevtools.spec | grep "Source"
    CHECK_RESULT $? 0 0 "Failed option: -A"
    spectool -S rpmdevtools.spec | grep "Source"
    CHECK_RESULT $? 0 0 "Failed option: -S"
    spectool -P rpmdevtools.spec | grep "Patch"
    CHECK_RESULT $? 0 0 "Failed option: -P"
    spectool -s 0 rpmdevtools.spec | grep "Source0"
    CHECK_RESULT $? 0 0 "Failed option: -s"
    spectool -p 0 rpmdevtools.spec | grep "Patch0"
    CHECK_RESULT $? 0 0 "Failed option: -p"
    spectool -d 'test test1' rpmdevtools.spec
    CHECK_RESULT $? 0 0 "Failed option: -d"
    spectool -g -C ./test_dir rpmdevtools.spec && test -e ./test_dir/*tar.xz
    CHECK_RESULT $? 0 0 "Failed option: -C"
    spectool -g -R rpmdevtools.spec && test -e ~/rpmbuild/SOURCES/*tar.xz 
    CHECK_RESULT $? 0 0 "Failed option: -R"
    test -e *tar.xz && spectool -g -f rpmdevtools.spec
    CHECK_RESULT $? 0 0 "Failed option: -f"
    rm *tar.gz
    spectool -g -n rpmdevtools.spec
    CHECK_RESULT $? 0 0 "Failed option: -n"
    spectool -D rpmdevtools.spec 
    CHECK_RESULT $? 0 0 "Failed option: -D"

    LOG_INFO "End to run test."
}

function post_test(){
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    userdel -r user_test
    rm *rpm
    rm -rf /ALT
    rm record*
    rm -r ./tmp_dir
    rm -rf ./test_dir
    rm -rf ~/rpmbuild
    rm -rf ./rpmdevtools
    rm rpmdevtools*
    LOG_INFO "End to restore the test environment."
}


main "$@"

