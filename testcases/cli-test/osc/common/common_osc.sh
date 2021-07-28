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
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-11-2
#@License       :   Mulan PSL v2
#@Desc          :   Public class
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function deploy_env() {
    cat >/root/.oscrc <<EOF
[general]
apiurl=http://117.78.1.88
no_verify=1
build-root=/root/osc/buildroot
[http://117.78.1.88]
user=test666
pass=test666@123
EOF
    branches_path=home:test666:branches:openEuler:Mainline
    currentDir=$(
        cd "$(dirname $0)" || exit 1
        pwd
    )
}

function clear_env() {
    cd $currentDir || exit 1
    rm -rf $branches_path /root/.oscrc
    DNF_REMOVE
}
