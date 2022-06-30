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
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/10
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of mutt command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "mutt sendmail"
    export LANG="en_US.UTF-8"
    muttFile=$(find / -name Muttrc)
    cp $muttFile /root/.muttrc
    echo 'set charset="utf-8"
    set rfc2047_parameters=yes
    set envelope_from=yes
    set use_from=yes
    set from=root@itdhz.com
    set realname="itdhz"' >>/root/.muttrc
    touch test.jar
    echo "test mutt from lisa" >sendmail
    version=$(rpm -qa mutt | awk -F "-" '{print$2}')
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mutt -help | grep "usage: mutt"
    CHECK_RESULT $?
    mutt -version | grep $version
    CHECK_RESULT $?
    mutt Lisa@163.com -s "test mutt01" <sendmail
    grep -E "From: itdhz <root@itdhz.com>|Subject: test mutt01|test mutt from lisa" /root/sent
    CHECK_RESULT $?
    mutt Lisa@163.com -s "test mutt02" -a test.jar <sendmail
    grep -E "Subject: test mutt02|Content-Disposition: attachment; filename=test.jar" /root/sent
    CHECK_RESULT $?
    mutt Lisa@163.com -s "test mutt03" -e 'set content_type="text/html"' <sendmail
    grep -E "Subject: test mutt03|Content-Type: text/html; charset=us-ascii" /root/sent
    CHECK_RESULT $?
    echo "test bb and cc" >sendmail
    mutt -s "test mutt04" -c lisa@gmail.com -b jack@server1.tecmint.com john@server1.tecmint.com <sendmail
    grep -E "To: john@server1.tecmint.com|Cc: lisa@gmail.com|Bcc: jack@server1.tecmint.com|Subject: test mutt04|test bb and cc" /root/sent
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf test.jar sendmail /root/sent /root/.muttrc
    DNF_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
