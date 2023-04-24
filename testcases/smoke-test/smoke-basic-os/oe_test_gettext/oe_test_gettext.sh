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
# @Author    :   geyaning
# @Contact   :   geyaning@uniontech.com
# @Date      :   2022-11-17
# @License   :   Mulan PSL v2
# @Desc      :   gettext Basic Functions test
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    DNF_INSTALL "gettext"
    local=$(localectl status | grep System | awk -F "=" '{print $2}')
    localectl set-locale LANG=en_US.UTF-8
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    cat > test.py << EOF
import os
import gettext

_ = gettext.gettext

string = "test"

LOCALE_DIR = os.path.abspath("locale")
gettext.bindtextdomain(string, LOCALE_DIR)
gettext.textdomain(string)


if __name__ == "__main__":
    print(_("hello world"))
EOF
    xgettext -k_ -o test.po test.py
    CHECK_RESULT $? 0 0 "Failed to execute the python file"
    sed -i "s/charset=CHARSET/charset=UTF-8/g" test.po
    sed -i "s/msgstr \"\"/msgstr \"你好\"/g" test.po
    CHECK_RESULT $? 0 0 "Description Failed to modify the test.po file"
    mkdir -p locale/zh_CN/LC_MESSAGES/
    mkdir -p locale/en_US/LC_MESSAGES/
    msgfmt -o locale/zh_CN/LC_MESSAGES/test.mo test.po
    CHECK_RESULT $? 0 0 "Can't generate mo file"
    python3 test.py | grep "你好"
    CHECK_RESULT $? 0 0 "test.py cannot be executed properly or Unable to filter necessary characters"
    xgettext -k_ -o us.po test.py
    CHECK_RESULT $? 0 0 "Unable to generate us.po"
    sed -i "s/charset=CHARSET/charset=UTF-8/g" us.po
    sed -i "s/msgstr \"\"/msgstr \"hello\"/g" us.po
    msgfmt -o locale/en_US/LC_MESSAGES/test.mo us.po
    CHECK_RESULT $? 0 0 ".mo files cannot be generated using us.po"
    LANG=en_US.UTF-8
    python3 test.py | grep "hello"
    CHECK_RESULT $? 0 0 "test.py cannot be executed properly or Unable to filter necessary characters"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -rf locale/ *.po test.py
    localectl set-locale LANG=${local}
    LOG_INFO "Finish environment cleanup!"
}

main $@
