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
#@Author    	:   Jevons
#@Contact   	:   1557927445@qq.com
#@Date      	:   2021-05-31 09:39:43
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   Take the test ls command as an example
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
source ../common/comlib.sh

function run_test()
{
    LOG_INFO "Start to run test."
    mkdir -p /auditlog_test
    dd if=dev/zero of=/auditlog_test.img count=5 bs=1G
    mkfs.ext3 -F /auditlog_test.img
    mount /auditlog_test.img /auditlog_test
    cp -raf /var/log/ /auditlog_test/
    sed -i sed -i 's/log_file = \/var\/log\/audit\/audit.log/log_file = \/auditlog_test\/log\/audit\/audit.log/g' "/etc/audit/auditd.conf"
    service auditd restart
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."

    LOG_INFO "End to restore the test environment."
}

main "$@"
