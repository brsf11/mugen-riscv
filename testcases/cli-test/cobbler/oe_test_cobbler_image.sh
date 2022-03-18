#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

###################################
#@Author    :   qinhaiqi
#@Contact   :   2683064908@qq.com
#@Date      :   2022/2/16
#@License   :   Mulan PSL v2
#@Desc      :   Test "cobbler image" command
###################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "cobbler httpd"
    systemctl start httpd
    systemctl start cobblerd
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run testcase."
    cobbler image add --name=OpenEuler1 
    CHECK_RESULT $? 0 0 "Failed option: image add"
    cobbler image copy --name=OpenEuler1 --newname=OpenEuler2
    CHECK_RESULT $? 0 0 "Failed option: image copy"
    cobbler image list | grep "OpenEuler2"
    CHECK_RESULT $? 0 0 "Failed option: image copy"
    cobbler image edit --name=openEuler1 --owners=tom
    CHECK_RESULT $? 0 0 "Failed option: image edit"
    cobbler image report --name=openEuler1 | grep "tom"
    CHECK_RESULT $? 0 0 "Failed option: image edit"
    cobbler image list | grep "OpenEuler"
    CHECK_RESULT $? 0 0 "Failed option: image list"
    cobbler image find | grep "OpenEuler"
    CHECK_RESULT $? 0 0 "Failed option: image find"
    cobbler image remove --name=OpenEuler1
    CHECK_RESULT $? 0 0 "Failed option: image remove"
    cobbler image list | grep "OpenEuler1"
    CHECK_RESULT $? 0 1 "Failed option: image remove"
    cobbler image rename --name=OpenEuler2 --newname=OpenEuler3
    CHECK_RESULT $? 0 0 "Failed option: image rename"
    cobbler image list | grep "OpenEuler3"
    CHECK_RESULT $? 0 0 "Failed option: image rename"
    cobbler image report --name=OpenEuler3 | grep "Name"
    CHECK_RESULT $? 0 0 "Failed option: image report"
    LOG_INFO "End to run testcase."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop httpd
    systemctl stop cobblerd
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
