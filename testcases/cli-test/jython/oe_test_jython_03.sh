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
    DNF_INSTALL "jython java-devel"
    ss=""
    for file in $(ls /usr/share/jython/javalib); do
        ss=$ss"/usr/share/jython/javalib/${file}:"
    done
    export CLASSPATH=$ss
    old_LANG=${LANG}
    export LANG=en_US.UTF-8
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."

    jython --print 2>&1 | grep "java -Xmx"
    CHECK_RESULT $? 0 0 "Failed to run command: jython --print"

    jython -J-Xmx768m --print 2>&1 | grep "java -Xmx768m"
    CHECK_RESULT $? 0 0 "Failed to run command: jython -Jarg"

    jython --profile 2>&1 | grep "instrumented profiler"
    CHECK_RESULT $? 0 0 "Failed to run command: jython --profile"

    jython -J-classpath $ss --boot -c "print 'test'" 2>&1 | grep "test"
    CHECK_RESULT $? 0 0 "Failed to run command: jython --boot"

    javac -d . ./common/Hello.java
    expect -c "
    log_file testlog
    spawn jython --jdb
    send \"run Hello\r\"
    expect eof
"
    grep "VM Started" testlog | grep 'Hello,world!'
    CHECK_RESULT $? 0 0 "Failed to run command: jython --jdb"

    LOG_INFO "Finish test!"

}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf testlog Hello*
    export LANG=${old_LANG}
    LOG_INFO "Finish environment cleanup!"
}

main "$@"