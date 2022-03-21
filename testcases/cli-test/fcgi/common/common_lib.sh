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
# @Date      	:   2022-3-23
# @License   	:   Mulan PSL v2
# @Desc      	:   the test of fcgi package
####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_fcgi() {
    CRTDIR1=$(
        cd "$(dirname $0)" || exit 1
        pwd
    )
    wget https://gitee.com/src-openeuler/fcgi/raw/master/2.4.2.tar.gz
    tar xzvf 2.4.2.tar.gz -C .

    cd ./fcgi2-2.4.2
    echo '#include "fcgi_stdio.h"
#include <stdlib.h>

void main(void)
{
    int count = 0;
    while(FCGI_Accept() >= 0)
        printf("hello, it is a fast cgi application\n"); 
}' >examples/echo.c

    ./autogen.sh
    ./configure
    make
    make install

    cd $CRTDIR1

    echo '#! /bin/cgi-fcgi -f
-connect :9006 ./fcgi2-2.4.2/examples/echo 1' >cmdFile

}

main "$@"
