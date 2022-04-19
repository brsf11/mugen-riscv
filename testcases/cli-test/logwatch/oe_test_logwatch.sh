#!/user/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author    	:   ye mengfei
# @Contact   	:   mengfei@isrc.iscas.ac.cn
# @Date      	:   2022-3-25
# @License   	:   Mulan PSL v2
# @Desc      	:   the test of logwatch package
####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function config_params() {
    LOG_INFO "Start to config params of the case."

    logwatch_version=$(rpm -qa logwatch | awk -F '-' '{print $2}')

    saveFileName=./logwatch_log.txt

    mailAddress1=${USER}@localhost
    anotherUser=mufiyemailuser
    mailAddress2=${anotherUser}@localhost

    LOG_INFO "End to config params of the case."
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL "logwatch postfix dovecot"
    echo 'Archives = No' >>/usr/share/logwatch/default.conf/logwatch.conf
    systemctl start dovecot
    flag = false
    if [$(getenforce | grep Enforcing)]; then
        setenforce 0
        flag=true
    fi
    systemctl start postfix
    useradd ${anotherUser}
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    logwatch --version | grep "Logwatch ${logwatch_version}"
    CHECK_RESULT $? 0 0 "logwatch version Test --version FAILED."

    # for --help and considering unknown argument
    ! logwatch --help 2>&1 | grep "Unknown option" && logwatch --help 2>&1 | grep "Usage: /usr/sbin/logwatch"
    CHECK_RESULT $? 0 0 "logwatch help Test --help FAILED."

    ! logwatch --usage 2>&1 | grep "Unknown option" && logwatch --usage 2>&1 | grep "Usage: /usr/sbin/logwatch"
    CHECK_RESULT $? 0 0 "logwatch usage Test --usage FAILED."

    # for --service argument in normal situation
    logwatch --service sshd --range All --detail high --output stdout \
        --format text --encode none | grep "Logwatch ${logwatch_version}"
    CHECK_RESULT $? 0 0 "logwatch normal service Test --service --range
                         --detail --output --format --encode FAILED."

    # for --service argument in html format
    logwatch --service rsyslogd --range All --detail med --debug 10 \
        --output stdout --format html --encode none | grep "<title>Logwatch  ${logwatch_version}"
    CHECK_RESULT $? 0 0 "logwatch normal service in html format Test --service --range 
                         --detail --debug --output --format --encode FAILED."

    # the below test is about the --html_wrap
    logwatch --service sshd --range Today --detail med --format html --html_wrap 5 | grep "/etc/ssh/"
    CHECK_RESULT $? 1 0 "logwatch html format wrap test --html_wrap FAILED."

    # for --logfile argument
    logwatch --logfile messages --range Today --detail low --debug 50 --output file \
        --filename ${saveFileName} --format text --encode none
    grep "Logwatch ${logwatch_version}" ${saveFileName}
    CHECK_RESULT $? 0 0 "logwatch save to file test --logfile --range --detail
                         --debug --output --filename --format --encode FAILED."

    # for testing send email to one host
    logwatch --service rsyslogd --range All --detail med --output mail --logdir /var/log \
        --mailto ${mailAddress1} --subject "logoflogwatch1" --hostformat none --encode base64
    CHECK_RESULT $? 0 0 "logwatch sendmail test --service --range --detail --output 
                         --logdir --mailto --subject --hostformat --encode FAILED.
                         position 1"
    SLEEP_WAIT 5
    grep "logoflogwatch1" /var/spool/mail/${USER}
    CHECK_RESULT $? 0 0 "logwatch sendmail test --service --range --detail --output 
                            --logdir --mailto --subject --hostformat --encode FAILED.
                            position 2"

    # for testing send email to multihost
    logwatch --service sshd --range Today --detail high --output mail \
        --mailto ${mailAddress1},${mailAddress2} --subject "logoflogwatch2" --hostformat splitmail
    CHECK_RESULT $? 0 0 "logwatch sendmail to multi host test --service --range
                        --detail --output --mailto --subject --hostformat FAILED.
                        position 1"

    SLEEP_WAIT 5
    grep "logoflogwatch2" /var/spool/mail/${USER}
    CHECK_RESULT $? 0 0 "logwatch sendmail to multi host test --service --range
                        --detail --output --mailto --subject --hostformat FAILED. 
                        position 2"

    grep "logoflogwatch2" /var/spool/mail/${anotherUser}
    CHECK_RESULT $? 0 0 "logwatch sendmail to multi host test --service --range
                        --detail --output --mailto --subject --hostformat FAILED.
                        position 3"

    # for testing --hostname argument
    logwatch --service sshd --range Today --detail 50 --hostname ${HOSTNAME} | grep "Logfiles for Host: ${HOSTNAME}"
    CHECK_RESULT $? 0 0 "logwatch hosname argument test --service --range
                         --detail --hostname FAILED."

    # for --hostlimit argument
    logwatch --service sshd --range Today --detail 50 --hostlimit non_${HOSTNAME} | grep "Logwatch ${logwatch_version}"
    CHECK_RESULT $? 1 0 "logwatch hostlimit argument test --service --range
                         --detail --hostlimit FAILED."

    # for --numeric argument(to add this, the ip will not be look up as gateway)
    logwatch --service sshd --range Today --detail 50 --numeric | grep "gateway"
    CHECK_RESULT $? 1 0 "logwatch numeric argument test --service --range
                         --detail --numeric FAILED."

    # for --archives
    cp /var/log/messages /var/log/messages-today
    if [$(logwatch --logFile messages --range All --archives | wc -l) -gt $(logwatch --logFile messages --range All | wc -l)]; then
        CHECK_RESULT $? 0 0 "logwatch archives argument test --logFile --archives FAILED."
    fi

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    sed -i '$d' /usr/share/logwatch/default.conf/logwatch.conf
    rm -rf ${saveFileName} /var/spool/mail/${USER} \
        /var/spool/mail/${anotherUser} /var/log/messages-today
    systemctl stop dovecot
    systemctl stop postfix
    userdel mufiyemailuser
    DNF_REMOVE
    if [${flag} = 'true']; then
        setenforce 1
    fi
    LOG_INFO "End to restore the test environment."
}

main "$@"
