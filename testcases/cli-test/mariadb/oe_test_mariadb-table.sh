#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   yangchenguang
# @Contact   :   yangchenguang@uniontech.com
# @Date      :   2022/08/12
# @License   :   Mulan PSL v2
# @Desc      :   Test mariadb table data
# #############################################

source "./common/lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    mariadb_init
    test -d /tmp/mariadbtab || mkdir /tmp/mariadbtab
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    pushd /tmp/mariadbtab
    mysql -uroot -hlocalhost -p123456 >tmp1_log <<EOF
use mariadb;
insert into testtable values('02','lisi');
update testtable set name='yang' where id=1;
select * from testtable;
quit
EOF
    grep lisi tmp1_log
    CHECK_RESULT $? 0 0 "insert table error"
    grep yang tmp1_log
    CHECK_RESULT $? 0 0 "update table error"
    mysql -uroot -hlocalhost -p123456 >tmp2_log <<EOF
use mariadb;
delete from testtable where id=1;
select * from testtable;
exit
EOF
    grep yang tmp2_log
    CHECK_RESULT $? 0 1 "delete table error"
    popd
    LOG_INFO "Finish testing!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    stat /tmp/mariadbtab && rm -fr /tmp/mariadbtab
    mariadb_clear
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
