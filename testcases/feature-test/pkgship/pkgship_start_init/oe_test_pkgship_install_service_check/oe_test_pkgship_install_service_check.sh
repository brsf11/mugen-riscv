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
#@Author    	:   Li, Meiting
#@Contact   	:   244349477@qq.com
#@Date      	:   2020-08-25
#@License   	:   Mulan PSL v2
#@Desc      	:   Pkgship items normal function test
#####################################

source ../../common_lib/pkgship_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    test -f ${YUM_PATH}/pkgship_yum.repo && rm -f ${YUM_PATH}/pkgship_yum.repo
    DNF_INSTALL "pkgship bc"
    
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    # Check admin
    cat /etc/passwd | grep pkgshipuser
    CHECK_RESULT $? 0 0 "The admin pkgshipuser doesn't create."

    $(bash /etc/pkgship/auto_install_pkgship_requires.sh redis)
    redis_pid=$(ps aux | grep redis | grep -v 'grep' | wc -l)
    if [[ $redis_pid -lt 1 ]]; then 
        CHECK_RESULT 1 1 0 "The redis service doesn't install or start by auto_install_pkgship_requires.sh"
    fi
    
    $(bash /etc/pkgship/auto_install_pkgship_requires.sh elasticsearch)
    es_pid=$(ps aux | grep elastic | grep -v 'grep' | wc -l)
    if [[ $es_pid -lt 1 ]]; then 
        CHECK_RESULT 1 1 0 "The elastic service doesn't install or start by auto_install_pkgship_requires.sh"
    fi
    
    # Check server start
    ACT_SERVICE
    CHECK_RESULT $? 0 0 "Start service failed."

    # Check file access
    check_file_access /usr/bin/pkgship pkgshipuser pkgshipuser 755
    check_file_access /usr/bin/pkgshipd pkgshipuser pkgshipuser 755
    check_file_access /opt/pkgship pkgshipuser pkgshipuser 750
    check_file_access /etc/pkgship/package.ini pkgshipuser pkgshipuser 640
    check_file_access /etc/pkgship/conf.yaml pkgshipuser pkgshipuser 644
    check_file_access /usr/lib/python3.8/site-packages/packageship pkgshipuser pkgshipuser 755
    check_file_access /lib/systemd/system/pkgship.service pkgshipuser pkgshipuser 640
    check_file_access /var/log/pkgship pkgshipuser pkgshipuser 755
    check_file_access /var/log/pkgship/log_info.log pkgshipuser pkgshipuser 644
    check_file_access /var/log/pkgship-operation pkgshipuser pkgshipuser 700
    check_file_access /var/log/pkgship-operation/uwsgi.log pkgshipuser pkgshipuser 644
    check_file_access /etc/pkgship/uwsgi_logrotate.sh pkgshipuser pkgshipuser 750

    # Check cmd
    mv ${SYS_CONF_PATH}/conf.yaml ${SYS_CONF_PATH}/conf.yaml.bak
    cp -p ../../common_lib/openEuler.yaml ${SYS_CONF_PATH}/conf.yaml
    chown pkgshipuser:pkgshipuser ${SYS_CONF_PATH}/conf.yaml
    pkgship init >/dev/null
    CHECK_RESULT $? 0 0 "pkgship init failed."
    pkgship dbs | grep "openeuler-lts"
    CHECK_RESULT $? 0 0 "Database openeuler init failed."

    # Close server
    ACT_SERVICE STOP
    CHECK_RESULT $? 0 0 "Stop service failed."
    
    LOG_INFO "End to run test."
}

function check_file_access() {
    file_name=$1
    expect_owner=$2
    expect_group=$3
    expect_code=$4
    ls -ld $file_name | awk '{print $3}' | grep $expect_owner
    CHECK_RESULT $? 0 0 "Check owner for $file_name failed."
    ls -ld $file_name | awk '{print $4}' | grep $expect_group
    CHECK_RESULT $? 0 0  "Check group for $file_name failed."
    echo "obase=8;ibase=2;$(ls -ld $file_name | awk '{print $1}' | sed 's/^[a-zA-Z-]//' | tr 'x|r|w' '1' | tr '-' '0')" | bc | grep $expect_code
    CHECK_RESULT $? 0 0  "Check access for $file_name failed."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
 
    rm -f ${SYS_CONF_PATH}/conf.yaml
    REVERT_ENV

    LOG_INFO "End to restore the test environment."
}

main $@

