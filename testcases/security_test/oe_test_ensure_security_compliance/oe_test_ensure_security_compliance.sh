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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2020/04/25
# @License   :   Mulan PSL v2
# @Desc      :   View configuration files to ensure security compliance
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "openscap  scap-security-guide"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    ls /usr/share/xml/scap/ssg/content/ | grep xml
    CHECK_RESULT $? 0 0 "xml not exist"
    oscap info /usr/share/xml/scap/ssg/content/ssg-ol7-ds.xml | grep Ref-Id
    CHECK_RESULT $? 0 0 "exec 'oscap info failed'"
    oscap info --profile pci-dss /usr/share/xml/scap/ssg/content/ssg-sl6-xccdf.xml | grep pci-dss
    CHECK_RESULT $? 0 0 "exec 'oscap info --profile pci-dss /usr/share/xml/scap/ssg/content/ssg-sl6-xccdf.xml' failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
