#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   chengweibin
# @Contact   :   chengweibin@uniontech.com
# @Date      :   2022-10-08
# @License   :   Mulan PSL v2
# @Desc      :   smoke basic os test-krb5
# ############################################
source "$OET_PATH/libs/locallibs/common_lib.sh"


function pre_test(){
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "krb5-server"
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    systemctl status krb5kdc  | grep "inactive"
    CHECK_RESULT $? 0 0 "krbekdc status abnormal"

    KCM=$(cat /etc/krb5.conf | grep default_ccache_name | awk '{print $3}')
    sed  -i "s/KCM/${KCM}/g" /etc/krb5.conf.d/kcm_default_ccache
    /usr/sbin/kdb5_util create -s -r EXAMPLE.COM << EOF
123
123
EOF
    re=$(ls /var/kerberos/krb5kdc/ | grep principal | wc -l)
    CHECK_RESULT ${re} 4 0 "krb5kdc config fail"

    systemctl start krb5kdc
    systemctl status krb5kdc | grep "running"
    CHECK_RESULT $? 0 0 "krb5kdc start success"

    systemctl start kadmin
    systemctl status kadmin | grep "running"
    CHECK_RESULT $? 0 0 "kadmin start success"

    kadmin.local << EOF
?
exit
EOF
    CHECK_RESULT $? 0 0 "kadmin config success"
    LOG_INFO "Finish test!"
}
function post_test(){
    LOG_INFO "start environment cleanup."
    systemctl stop krb5kdc
    systemctl stop kadmin
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main $@
