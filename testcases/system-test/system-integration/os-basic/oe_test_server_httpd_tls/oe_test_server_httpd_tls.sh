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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-4-9
# @License   :   Mulan PSL v2
# @Desc      :   Enable specific versions of TLSv1.x
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
	LOG_INFO "Start to prepare the test environment."
	DNF_INSTALL "httpd mod_ssl"
	LOG_INFO "End to prepare the test environment."
}

function run_test() {
	LOG_INFO "Start to run test."
	systemctl enable httpd
	systemctl start httpd
        SLEEP_WAIT 1
	systemctl status httpd | grep running
	CHECK_RESULT $?
	sed -i "s/#SSLProtocol all -SSLv3/SSLProtocol -all +TLSv1.3/g" /etc/httpd/conf.d/ssl.conf
	grep "SSLProtocol -all +TLSv1.3" /etc/httpd/conf.d/ssl.conf
	CHECK_RESULT $?
	systemctl restart httpd
	CHECK_RESULT $?
	openssl s_client -connect ${NODE1_IPV4}:443 -tls1_3 <<EOF

EOF
	CHECK_RESULT $?
	sed -i "s/SSLProtocol -all +TLSv1.3/#SSLProtocol all -SSLv3/g" /etc/httpd/conf.d/ssl.conf
	CHECK_RESULT $?
	LOG_INFO "End to run test."
}

function post_test() {
	LOG_INFO "Start to restore the test environment."
	systemctl reload httpd
	systemctl stop httpd
	DNF_REMOVE
	LOG_INFO "End to restore the test environment."
}

main "$@"
