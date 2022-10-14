# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author    	:   zu binshuo
# @Contact   	:   binshuo@isrc.iscas.ac.cn
# @Date      	:   2022-7-15
# @License   	:   Mulan PSL v2
# @Desc      	:   the test of pngcrush package
####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL jython
    ss=""
    for file in $(ls /usr/share/jython/javalib); do
        ss=$ss"/usr/share/jython/javalib/${file}:"
    done
    export CLASSPATH=$ss
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."

    jython --help 2>&1 | grep "usage: jython"
    CHECK_RESULT $? 0 0 "Failed to run command: jython --help"
    jython -h 2>&1 | grep "usage: jython"
    CHECK_RESULT $? 0 0 "Failed to run command: jython -h"

    jython --version 2>&1 | grep "Jython [[:digit:]]*"
    CHECK_RESULT $? 0 0 "Failed to run command: jython --version"
    jython -V 2>&1 | grep "Jython [[:digit:]]*"
    CHECK_RESULT $? 0 0 "Failed to run command: jython -V"

    jython -c "print 'test'" 2>&1 | grep "test"
    CHECK_RESULT $? 0 0 "Failed to run command: jython -c"

    jython -i -c "str='test';print str;exit(0)" 2>&1 | grep "test"
    CHECK_RESULT $? 0 0 "Failed to run command: jython -i"

    jython -S -c "exit(0)" 2>&1 | grep "is not defined"
    CHECK_RESULT $? 0 0 "Failed to run command: jython -S"

    jython -Qnew -c "a = 2/3; assert type(a)==float"
    CHECK_RESULT $? 0 0 "Failed to run command: jython -Q"

    jython -B -c "from java.util import Date;print Date()" 
    CHECK_RESULT $? 0 0 "Failed to run command: jython -B"

    jython -v -c "" 2>&1 | grep -m 1 "import"
    CHECK_RESULT $? 0 0 "Failed to run command: jython -v"

    jython -vv -c "" 2>&1 | grep -m 1 "__init__"
    CHECK_RESULT $? 0 0 "Failed to run command: jython -vv"

    jython ./common/test.py 2>&1 | grep "test"
    CHECK_RESULT $? 0 0 "Failed to run command: jython [file]"

    LOG_INFO "Finish test!"

}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"