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
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date          :   2021-10-24 14:00:43
#@License   	:   Mulan PSL v2
#@Desc          :   verification ansible's commnd
#####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function Pre_Test() {
    DNF_INSTALL ansible
    sed -i '1i\${NODE2_IPV4}' /etc/ansible/hosts
    expect <<-END
    spawn ssh-keygen
    expect ":"
    send "\n"
    expect ":"
    send "\n"
    expect ":"
    send "\n"
    expect eof
END
    expect <<-END
    spawn ssh-copy-id root@${NODE2_IPV4}
    expect "])?"
    send "yes\n"
    expect "password:"
    send "${NODE2_PASSWORD}\n"
    expect eof
END
}

function Post_Test() {
    rm -rf /etc/ansible/hosts
    DNF_REMOVE
    rm -rf /root/.ssh
}
main "$@"
