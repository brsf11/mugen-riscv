#!/usr/bin/bash

# Copyright (c) 2021. Ding Taixin, 1315774958@qq.com. ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

####################################
#@Author        :   Ding Taixin
#@Contact       :   1315774958@qq.com
#@Date          :   2021/7/26
#@License       :   Mulan PSL v2
#@Desc          :   Test "chacl" command
#####################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function config_params() {
    myfilelist="f f-l f-R dir/subfile"
}

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    
    DNF_INSTALL acl
    mkdir -p dir dir-b dir-d
    touch $myfilelist
    uid=$(whoami)
    gid=$(id -gn)
    
    LOG_INFO "End to prepare the test environment."
} 

################################################################################
# Usage:
#         chacl acl pathname...
#         chacl -b acl dacl pathname...
#         chacl -d dacl pathname...
#         chacl -R pathname...
#         chacl -D pathname...
#         chacl -B pathname...
#         chacl -l pathname...    [not IRIX compatible]
#         chacl -r pathname...    [not IRIX compatible]
################################################################################

function run_test() {
    LOG_INFO "Start to run test."
    
    ### No Options ###
    (getfacl f | grep -e "^user::rw-" -e "^group::r--" -e "^other::r--" -c | grep -q 3) \
        && chacl u::rwx,g::r-x,o::r--,u:$uid:r--,g:$gid:r--,m::r-x f \
        && (getfacl f | grep -e "^user::rwx" -e "^group::r-x" -e "^other::r--" \
                            -e "^user:$uid:r--" -e "^mask::r-x" -e "^group:$gid:r--" -c | grep -q 6)
    CHECK_RESULT $? 0 0 "L$LINENO: No Options No Pass"    
    
    ### -b ###
    setfacl -d -m user::rwx dir-b \
        && (getfacl dir-b | grep -e "^user:$uid:" -e "^default:group:$gid:" -c | grep -q 0) \
        && chacl -b u::rwx,g::r-x,o::r--,u:$uid:rwx,m::rw u::rwx,g::r-x,o::rwx,g:$gid:r--,m::r-x dir-b \
        && (getfacl dir-b | grep -e "^user:$uid:" -e "^default:group:$gid:" -c | grep -q 2) 
    CHECK_RESULT $? 0 0 "L$LINENO: -b No Pass"
   
    ### -d ###
    setfacl -d -m user::rwx dir-d \
        && (getfacl dir-d | grep -e "^default:group:$gid:r--" -c | grep -q 0) \
        && chacl -d u::rwx,g::r-x,o::rwx,g:$gid:r--,m::r-x dir-d \
        && (getfacl dir-d | grep -e "^default:group:$gid:r--" -c | grep -q 1) 
    CHECK_RESULT $? 0 0 "L$LINENO: -d No Pass"
    
    ### -R ###
    setfacl -m user:${uid}:rwx f-R \
        && (getfacl f-R | grep -e "^user:$uid:rwx" -e "^mask::rwx" -c | grep -q 2) \
        && chacl -R f-R \
        && (getfacl f-R | grep -e "^user:$uid:" -e "^mask:" -c | grep -q 0)
    CHECK_RESULT $? 0 0 "L$LINENO: -R No Pass" 
    
    ### -D ###
    setfacl -d -m user:${uid}:rwx dir \
        && (getfacl dir | grep -c "^default" | grep -q 5) \
        && chacl -D dir \
        && (getfacl dir | grep -c "^default" | grep -q 0)

    ### -B ###
    chacl -B f \
        && (getfacl f | grep -e "^user::rwx" -e "^group::r-x" -e "^other::r--" -c | grep -q 3)
    CHECK_RESULT $? 0 0 "L$LINENO: -B No Pass" 
    
    ### -l ###
    chacl -l f-l | grep -qG -e "^f-l \[u::rw-,g::r--,o::r--\]"
    CHECK_RESULT $? 0 0 "L$LINENO: -l No Pass" 
    
    ### -r ###
    (getfacl dir/subfile | grep -e "^mask:" -c | grep -q 0)\
        && chacl -r u::rwx,g::r-x,o::r--,m::rx dir \
        && (getfacl dir/subfile | grep -e "^mask::r-x$" -c | grep -q 1)
    CHECK_RESULT $? 0 0 "L$LINENO: -r No Pass" 

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    
    DNF_REMOVE 
    rm -rf dir dir-b dir-d $myfilelist
    
    LOG_INFO "End to restore the test environment."
}

main "$@"
