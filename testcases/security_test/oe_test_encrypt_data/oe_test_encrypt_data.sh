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
# @Date      :   2020/04/22
# @License   :   Mulan PSL v2
# @Desc      :   Encrypt data on unencrypted devices
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function config_params() {
    LOG_INFO "Start loading data!"
    TEST_DISK="/dev/$(lsblk | grep disk | sed -n 2p | awk '{print$1}')"
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environmental preparation."
    echo "n

p


+100M
w" | fdisk "${TEST_DISK}"
    ls /mnt/test_encrypted && rm -rf /mnt/test_encrypted
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    cryptsetup-reencrypt --new --reduce-device-size 8M "${TEST_DISK}"1 <<EOF


EOF
    cryptsetup open "${TEST_DISK}"1 test_encrypted <<EOF

EOF
    CHECK_RESULT $?
    mkdir /mnt/test_encrypted
    mkfs.ext4 /dev/mapper/test_encrypted -F
    mount /dev/mapper/test_encrypted /mnt/test_encrypted
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /mnt/test_encrypted
    cryptsetup close test_encrypted
    rm -rf /mnt/test_encrypted
    mkfs.ext4 ${TEST_DISK}1 -F
    echo "d

w" | fdisk "${TEST_DISK}"
    DNF_REMOVE
    mkfs.ext4 ${TEST_DISK} -F
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
