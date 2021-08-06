#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date      	:   2020-10-10 09:30:43
#@License   	:   Mulan PSL v2
#@Desc      	:   verification opencc‘s command
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "openscap scap-security-guide"
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    oscap -V | grep "Version"
    CHECK_RESULT $?
    oscap --help | grep "Usage:"
    CHECK_RESULT $?
    oscap --version | grep "Version"
    CHECK_RESULT $?
    oscap info /usr/share/xml/scap/ssg/content/ssg-firefox-ds.xml | grep -E "Imported:|Stream:|Generated:|Version:|Checklists:|Checks:|Dictionaries:"
    CHECK_RESULT $?
    oscap info /usr/share/xml/scap/ssg/content/ssg-firefox-xccdf.xml | grep -E "Imported:|Generated:|Referenced check files:"
    CHECK_RESULT $?
    cd /usr/share/xml/scap/ssg/content/
    oscap oval eval --directives directives.xml --without-syschar --results oval-results.xml ssg-firefox-oval.xml
    CHECK_RESULT $?
    oscap oval eval --directives directives.xml --without-syschar --datastream-id ds.xml --oval-id oval.xml --results oval-results.xml ssg-firefox-oval.xml
    CHECK_RESULT $?
    oscap xccdf generate guide ssg-firefox-xccdf.xml >guide.html
    CHECK_RESULT $?
    test -f guide.html
    CHECK_RESULT $?
    oscap xccdf generate guide --profile standard ssg-ol7-xccdf.xml >guide1.html
    CHECK_RESULT $?
    test -f guide1.html
    CHECK_RESULT $?
    oscap xccdf eval --profile standard --results xccdf-results.xml ssg-ol7-xccdf.xml
    CHECK_RESULT $?
    oscap ds sds-split ssg-rhel7-ds.xml extracted/
    CHECK_RESULT $?
    test -d extracted
    CHECK_RESULT $?
    oscap ds sds-validate ssg-rhel7-ds.xml
    CHECK_RESULT $?
    oscap cpe validate ssg-rhel7-cpe-oval.xml
    CHECK_RESULT $?
    oscap xccdf eval --results results.xml --profile xccdf_org.ssgproject.content_profile_pci-dss ssg-rhel7-ds.xml | grep -E "Title|Rule|Ident|Result"
    CHECK_RESULT $?
    oscap xccdf generate report --output report.html results.xml
    CHECK_RESULT $?
    test -f report.html
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
