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
#@Desc      :   Test "cobbler profile" command
###################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL "cobbler httpd"
    mount /dev/cdrom /mnt
    systemctl start httpd
    systemctl start cobblerd
    cobbler distro add --name=OpenEuler --owners=root --boot-loader=grub --initrd=/mnt/images/pxeboot/initrd.img --kernel=/mnt/isolinux/vmlinuz
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run testcase."
    cobbler profile add --name=OpenEuler1 --distro=OpenEuler 
    CHECK_RESULT $? 0 0 "Failed option: profile add"
    cobbler profile copy --name=OpenEuler1 --newname=OpenEuler2
    CHECK_RESULT $? 0 0 "Failed option: profile copy"
    cobbler profile list | grep "OpenEuler2"
    CHECK_RESULT $? 0 0 "Failed option: profile copy"
    cobbler profile dumpvars --name=OpenEuler1 | grep "allow_duplicate_hostnames"
    CHECK_RESULT $? 0 0 "Failed option: profile dumpvars"
    cobbler profile edit --name=openEuler1 --owners=tom
    CHECK_RESULT $? 0 0 "Failed option: profile edit"
    cobbler profile report --name=openEuler1 | grep "tom"
    CHECK_RESULT $? 0 0 "Failed option: profile edit"
    cobbler profile list | grep "OpenEuler"
    CHECK_RESULT $? 0 0 "Failed option: profile list"
    cobbler profile find | grep "OpenEuler"
    CHECK_RESULT $? 0 0 "Failed option: profile find"
    cobbler profile remove --name=OpenEuler1
    CHECK_RESULT $? 0 0 "Failed option: profile remove"
    cobbler profile list | grep "OpenEuler1"
    CHECK_RESULT $? 0 1 "Failed option: profile remove"
    cobbler profile rename --name=OpenEuler2 --newname=OpenEuler3
    CHECK_RESULT $? 0 0 "Failed option: profile rename"
    cobbler profile list | grep "OpenEuler3"
    CHECK_RESULT $? 0 0 "Failed option: profile rename"
    cobbler profile report --name=OpenEuler3 | grep "Name"
    CHECK_RESULT $? 0 0 "Failed option: profile report"
    cobbler profile get-autoinstall --name=OpenEuler3
    CHECK_RESULT $? 0 0 "Failed option: profile get-autoinstall"
    LOG_INFO "End to run testcase."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    umount /dev/cdrom
    systemctl stop httpd
    systemctl stop cobblerd
    DNF_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
