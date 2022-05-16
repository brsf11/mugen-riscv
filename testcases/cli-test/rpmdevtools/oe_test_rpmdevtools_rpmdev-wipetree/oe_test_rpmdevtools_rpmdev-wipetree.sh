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
#@Desc      	:   test rpmdev-wipetree rpmelfsym rpmfile rpminfo rpmls rpmpeek rpmsodiff rpmsoname
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "rpmdevtools gcc"
    useradd user_test
    su user_test -c "mkdir -p /home/user_test/rpmbuild/RPMS/${NODE1_FRAME}"
    pkg_name=$(dnf list | head -n 3 | tail -n 1 | awk '{print $1}' | awk 'BEGIN {FS="."} {print $1}')
    yumdownloader ${pkg_name}
    chown user_test *rpm
    chmod 755 *rpm
    mv *rpm /home/user_test/rpmbuild/RPMS/${NODE1_FRAME}

    yumdownloader ${pkg_name}
    mkdir -p /ALT/Sisyphus/files/i586/RPMS
    mkdir -p /ALT/Sisyphus/files/noarch/RPMS
    mkdir -p /ALT/Sisyphus/files/SRPMS
    cp -f *rpm /ALT/Sisyphus/files/SRPMS/
    cp -f *rpm /ALT/Sisyphus/files/i586/RPMS/
    cp -f *rpm /ALT/Sisyphus/files/noarch/RPMS

    yumdownloader gcc
    pkg_name1=gcc
    mkdir ./tmp_dir

    LOG_INFO "End of environmental preparation."
}

function run_test() {
    LOG_INFO "Start to run test."

    test -f /home/user_test/rpmbuild/RPMS/${NODE1_FRAME}/*rpm
    CHECK_RESULT $? 0 0 "Failed pre_test"
    su user_test -c "rpmdev-wipetree"
    test -f /home/user_test/rpmbuild/RPMS/${NODE1_FRAME}/*rpm
    CHECK_RESULT $? 1 0 "Failed command: rpmdev-wipetree"

    rpmelfsym -p ${pkg_name}*rpm | grep "/usr/.*"
    CHECK_RESULT $? 0 0 "Failed option: -p"
    rpmelfsym -h | grep -A 1 "Usage:" | grep "rpmelfsym"
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmelfsym -a | grep "${pkg_name}"
    CHECK_RESULT $? 0 0 "Failed option: -a"

    rpmfile -p ${pkg_name}*rpm | grep "/usr/.*"
    CHECK_RESULT $? 0 0 "Failed option: -p"
    rpmfile -h | grep -A 1 "Usage:" | grep "rpmfile"
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmfile -a | grep "${pkg_name}"
    CHECK_RESULT $? 0 0 "Failed option: -a"

    rpminfo -h | grep "Usage: rpminfo"
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpminfo -v ${pkg_name1} | grep "${pkg_name1}"
    CHECK_RESULT $? 0 0 "Failed option: -v"
    rpminfo -q ${pkg_name1} | grep "${pkg_name1}.*"
    CHECK_RESULT $? 0 0 "Failed option: -q"
    rpminfo -qq ${pkg_name1} | grep "${pkg_name1}.*"
    CHECK_RESULT $? 0 0 "Failed option: -qq"
    rpminfo -i -o record
    test -f record
    CHECK_RESULT $? 0 0 'Failed option: -i -o'
    rpminfo -e ${pkg_name1} | grep -A 20 "${pkg_name1}.*" | grep "/usr/bin"
    CHECK_RESULT $? 0 0 "Failed option: -e"
    rpminfo -l ${pkg_name1} | grep -A 20 "${pkg_name1}.*" | grep "/usr/lib"
    CHECK_RESULT $? 0 0 "Failed option: -l"
    rpminfo -p ${pkg_name1} | grep "PIC"
    CHECK_RESULT $? 0 0 "Failed option: -p"
    rpminfo -np ${pkg_name1}
    CHECK_RESULT $? 0 0 "Failed option: -np"
    rpminfo -P ${pkg_name1}
    CHECK_RESULT $? 0 0 "Failed option: -P"
    rpminfo -nP ${pkg_name1}
    CHECK_RESULT $? 0 0 "Failed option: -nP"
    rpminfo -r ${pkg_name1}
    CHECK_RESULT $? 0 0 "Failed option: -r"
    rpminfo -ro ${pkg_name1} | grep "PIC"
    CHECK_RESULT $? 0 0 "Failed option: -ro"
    rpminfo -s -o record1 ${pkg_name1}*rpm
    num_record1=$(ls -l record1* | wc -l)
    test ${num_record1} -ge 1
    CHECK_RESULT $? 0 0 "Failed option: -s "
    rpminfo -t ${pkg_name1} | grep "PIC"
    CHECK_RESULT $? 0 0 "Failed option: -t"
    rpminfo -T ./tmp_dir ${pkg_name1}*rpm

    rpmls -l ${pkg_name}*rpm | grep "${pkg_name}"
    CHECK_RESULT $? 0 0 "Failed command: rpmls"

    rpmpeek -h | grep -A 1 "Usage:" | grep "rpmpeek"
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmpeek ${pkg_name}*rpm ls -l | grep "usr"
    CHECK_RESULT $? 0 0 "Failed command: rpmpeek"
    rpmpeek -n ${pkg_name}*rpm ls -l
    CHECK_RESULT $? 0 0 "Failed option: -n"

    rpmsodiff -h | grep -A 1 "Usage:" | grep "rpmsodiff"
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmsodiff ${pkg_name}*rpm ${pkg_name}*rpm
    CHECK_RESULT $? 0 0 "Failed command: rpmsodiff"

    rpmsoname -h | grep -A 1 "Usage:" | grep "rpmsoname"
    CHECK_RESULT $? 0 0 "Failed option: -h"
    rpmsoname -p ${pkg_name}*rpm | grep "/usr/lib64"
    CHECK_RESULT $? 0 0 "Failed option: -p"
    rpmsoname ${pkg_name}*rpm | grep "/usr"
    CHECK_RESULT $? 0 0 "Failed command: rpmsoname"

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    userdel -rf user_test
    rm -rf /ALT *rpm record* ./tmp_dir

    LOG_INFO "End to restore the test environment."
}

main "$@"
