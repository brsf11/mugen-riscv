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
#@Author    	:   ice-kylin
#@Contact   	:   wminid@yeah.net
#@Date      	:   2021-08-07
#@License   	:   Mulan PSL v2
#@Desc      	:   command test cronie
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    USER_NAME='test_user'
    useradd $USER_NAME
    DNF_INSTALL "cronie"
    echo "echo \"Hello World: \$(date)\" >> $(pwd)/rst.txt" > ./test.sh
    chmod 777 ./test.sh
    echo "echo \"\$(whoami): \$(date)\" >> ~/rst.txt" > /home/"$USER_NAME"/test.sh
    chmod 777 /home/"$USER_NAME"/test.sh
    crontab -l > ./cron.bak
    crontab -u "$USER_NAME" -l > /home/"$USER_NAME"/cron.bak
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    crontab -V
    CHECK_RESULT $? 0 0 "log message: Failed to run command: crontab -V"
    cp ./cron.bak ./cron.test
    echo "* * * * * $(pwd)/test.sh" >> ./cron.test && crontab ./cron.test
    CHECK_RESULT $? 0 0 "log message: Failed to run command: echo \"* * * * * \$(pwd)/test.sh\" >>./cron.test && crontab ./cron.test"
    crontab -l | grep "* * * * * $(pwd)/test.sh"
    CHECK_RESULT $? 0 0 "log message: Failed to run command: crontab -l"
    SLEEP_WAIT 150
    cat "$(pwd)/rst.txt" | grep -c 'Hello World' | grep "[2-9]"
    CHECK_RESULT $? 0 0 "log message: The service may not be running properly"
    crontab -r
    CHECK_RESULT $? 0 0 "log message: Failed to run command: crontab -r"
    crontab -l
    CHECK_RESULT $? 1 0 "log message: Failed to remove the current crontab"
    cp /home/"$USER_NAME"/cron.bak /home/"$USER_NAME"/cron.test
    echo "* * * * * /home/""$USER_NAME""/test.sh" >> /home/"$USER_NAME"/cron.test && crontab -u "$USER_NAME" /home/"$USER_NAME"/cron.test
    CHECK_RESULT $? 0 0 "log message: Failed to run command: echo \"* * * * * /home/\"\"\$USER_NAME\"\"/test.sh\" >> /home/\"\$USER_NAME\"/cron.test && crontab /home/\"\$USER_NAME\"/cron.test"
    crontab -u "$USER_NAME" -l | grep "* * * * * /home/""$USER_NAME""/test.sh"
    CHECK_RESULT $? 0 0 "log message: Failed to run command: crontab -u \"\$USER_NAME\" -l"
    SLEEP_WAIT 150
    cat /home/"$USER_NAME"/rst.txt | grep -c "$USER_NAME" | grep "[2-9]"
    CHECK_RESULT $? 0 0 "log message: The service may not be running properly"
    echo -ne 'Y' | crontab -u "$USER_NAME" -ri
    CHECK_RESULT $? 0 0 "log message: Failed to run command: echo -ne 'Y' | crontab -u \"\$USER_NAME\" -ri"
    crond -V
    CHECK_RESULT $? 0 0 "log message: Failed to run command: crond -V"
    cronnext -h
    CHECK_RESULT $? 0 0 "log message: Failed to run command: cronnext -h"
    cronnext -V
    CHECK_RESULT $? 0 0 "log message: Failed to run command: cronnext -V"
    anacron -h
    CHECK_RESULT $? 0 0 "log message: Failed to run command: anacron -h"
    anacron -V
    CHECK_RESULT $? 0 0 "log message: Failed to run command: anacron -V"
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    crontab ./cron.bak
    crontab -u "$USER_NAME" /home/"$USER_NAME"/cron.bak
    DNF_REMOVE
    rm -rf test.sh rst.txt cron.bak cron.test
    userdel -r $USER_NAME
    LOG_INFO "End to restore the test environment."
}

main "$@"
