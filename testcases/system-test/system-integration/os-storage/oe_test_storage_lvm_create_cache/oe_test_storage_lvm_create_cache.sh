#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   duanxuemin
# @Contact   :   52515856@qq.com
# @Date      :   2020-05-07
# @License   :   Mulan PSL v2
# @Desc      :   Create LVM cache volume
# ############################################
source ../common/storage_disk_lib.sh
function pre_test() {
    LOG_INFO "Start loading data!"
    check_free_disk 
    LOG_INFO "Loading data is complete!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    pvcreate -y /dev/${local_disk} /dev/${local_disk1}
    pvdisplay | grep "PV Name" | grep /dev/${local_disk}
    CHECK_RESULT $?
    vgcreate openeulertest /dev/${local_disk} /dev/${local_disk1}
    vgdisplay | grep "VG Name" | grep openeulertest
    CHECK_RESULT $?
    lvcreate -y -L 50MB -n test openeulertest /dev/${local_disk}
    lvcreate --type cache-pool -L 1G -n cpool openeulertest /dev/${local_disk1} -y
    lvs -a -o name,size,attr,devices openeulertest
    CHECK_RESULT $?
    lvconvert -y --type cache --cachepool cpool openeulertest/test
    CHECK_RESULT $?
    lvs -a -o name,size,attr,devices openeulertest
    CHECK_RESULT $?
    lvconvert --type thin-pool openeulertest/test /dev/${local_disk} -y
    lvs -a -o name,size,attr,devices openeulertest
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    vgremove -y openeulertest
    pvremove -y /dev/${local_disk1} /dev/${local_disk}
    LOG_INFO "Finish environment cleanup."
}

main $@
