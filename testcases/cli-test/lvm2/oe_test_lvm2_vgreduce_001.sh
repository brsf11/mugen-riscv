#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

source ./common/disk_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL lvm2
    check_free_disk
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    pvcreate -y /dev/${local_disk} /dev/${local_disk1}
    CHECK_RESULT $? 0 0 "failed to create PV"
    pvs | grep "/dev/${local_disk}" && pvs | grep "/dev/${local_disk1}"
    CHECK_RESULT $? 0 0 "failed to create PV"
    vgcreate test /dev/${local_disk}
    CHECK_RESULT $? 0 0 "failed to create VG"
    vgdisplay | grep "VG Name" | grep "test"
    CHECK_RESULT $? 0 0 "failed to create VG"
    vgextend test /dev/${local_disk1} | grep "successfully extended"
    CHECK_RESULT $? 0 0 "failed to extend VG test"
    pvs | grep "/dev/${local_disk1}" | grep "test"
    CHECK_RESULT $? 0 0 "failed to create PV"
    vgreduce test /dev/${local_disk1} | grep "Removed"
    CHECK_RESULT $? 0 0 "failed to reduce VG"
    vgremove -f test
    vgcreate test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $? 0 0 "failed to create VG"
    vgextend test /dev/${local_disk1} | grep "successfully extended"
    CHECK_RESULT $? 0 0 "failed to extend VG"
    vgreduce test /dev/${local_disk1} -d | grep "Removed"
    CHECK_RESULT $? 0 0 "failed to reduce VG -d"
    vgremove -f test
    vgcreate test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $? 0 0 "failed to create VG"
    vgextend test /dev/${local_disk1} | grep "successfully extended"
    CHECK_RESULT $? 0 0 "failed to extend VG"
    vgreduce test /dev/${local_disk1} --autobackup y | grep "Removed"
    CHECK_RESULT $? 0 0 "failed to reduce VG --autobackup"
    vgremove -f test
    vgcreate test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $? 0 0 "failed to create VG"
    vgextend test /dev/${local_disk1} | grep "successfully extended"
    CHECK_RESULT $? 0 0 "failed to extend VG"
    vgreduce test /dev/${local_disk1} -f | grep "Removed"
    CHECK_RESULT $? 0 0 "failed to reduce VG -f"
    vgremove -f test
    vgcreate test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $? 0 0 "failed to create VG"
    vgextend test /dev/${local_disk1} | grep "successfully extended"
    CHECK_RESULT $? 0 0 "failed to extend VG --metadatatype"
    vgreduce test /dev/${local_disk1} --reportformat json | grep '{'
    CHECK_RESULT $? 0 0 "failed to reduce VG --reportformat"
    vgremove -f test
    vgcreate test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $? 0 0 "failed to create VG"
    vgextend test /dev/${local_disk1} | grep "successfully extended"
    CHECK_RESULT $? 0 0 "failed to extend VG"
    vgreduce test /dev/${local_disk1} -q | grep 'Removed'
    CHECK_RESULT $? 0 0 "failed to reduce VG -q"    
    vgremove -f test
    vgcreate test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $? 0 0 "failed to create VG"
    vgextend test /dev/${local_disk1} | grep "successfully extended"
    CHECK_RESULT $? 0 0 "failed to extend VG"
    vgreduce test /dev/${local_disk1} -t | grep 'TEST'
    CHECK_RESULT $? 0 0 "failed to reduce VG -t"
    vgremove -f test
    vgcreate test /dev/${local_disk} | grep "successfully created"
    CHECK_RESULT $? 0 0 "failed to create VG"
    vgextend test /dev/${local_disk1} | grep "successfully extended"
    CHECK_RESULT $? 0 0 "failed to extend VG"
    vgreduce test /dev/${local_disk1} -v | grep 'Removed'
    CHECK_RESULT $? 0 0 "failed to reduce VG -v"
    vgreduce --help | grep "vgreduce"
    CHECK_RESULT $? 0 0 "check vgreduce --help failed"
    vgreduce --longhelp | grep variables
    CHECK_RESULT $? 0 0 "check vgreduce --longhelp failed"
    LOG_INFO "End executing testcase!"
}
function post_test() {
    LOG_INFO "Start environment cleanup."
    vgremove -f test
    pvremove -f /dev/${local_disk} /dev/${local_disk1}
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
