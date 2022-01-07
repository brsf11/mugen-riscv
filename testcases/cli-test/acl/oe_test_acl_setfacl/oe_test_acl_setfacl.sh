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
#@Desc          :   Test "setfacl" command
#####################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function config_params() {
    myfilelist="myacl f f-M f-set f-set-file f-mask f-n f-b factual f-test"
}
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    
    DNF_INSTALL acl
    mkdir -p dir/subdir dir2/subdir2
    touch $myfilelist
    ln -s factual filelink
    uid=$(whoami)
    gid=$(id -gn)
    
    LOG_INFO "End to prepare the test environment."
}

################################################################################
# setfacl 2.2.53 -- set file access control lists
# Usage: setfacl [-bkndRLP] { -m|-M|-x|-X ... } file ...
#   -m, --modify=acl        modify the current ACL(s) of file(s)
#   -M, --modify-file=file  read ACL entries to modify from file
#   -x, --remove=acl        remove entries from the ACL(s) of file(s)
#   -X, --remove-file=file  read ACL entries to remove from file
#   -b, --remove-all        remove all extended ACL entries
#   -k, --remove-default    remove the default ACL
#       --set=acl           set the ACL of file(s), replacing the current ACL
#       --set-file=file     read ACL entries to set from file
#       --mask              do recalculate the effective rights mask
#   -n, --no-mask           don't recalculate the effective rights mask
#   -d, --default           operations apply to the default ACL
#   -R, --recursive         recurse into subdirectories
#   -L, --logical           logical walk, follow symbolic links
#   -P, --physical          physical walk, do not follow symbolic links
#       --restore=file      restore ACLs (inverse of `getfacl -R')
#       --test              test mode (ACLs are not modified)
#   -v, --version           print version and exit
#   -h, --help              this help text
################################################################################

function run_test() {
    LOG_INFO "Start to run test."
    
    ### -m ###
    (getfacl f | grep -e "^mask::" -c | grep -q 0) \
        && setfacl -m m::rx f && (getfacl f | grep -qe "^mask::r-x")
    CHECK_RESULT $? 0 0 "L$LINENO: -m No Pass" 
   
    ### -M ###
    echo "m::rx" >myacl
    (getfacl f-M | grep -e "^mask::" -c | grep -q 0) \
        && setfacl -Mmyacl f-M && (getfacl f-M | grep -qe "^mask::r-x")
    CHECK_RESULT $? 0 0 "L$LINENO: -M No Pass" 
   
    ### -x ###
    setfacl -x m f && (getfacl f | grep -e "^mask:" -c | grep -q 0)
    CHECK_RESULT $? 0 0 "L$LINENO: -x No Pass" 
   
    ### -X ###
    echo "m" >myacl
    setfacl  -Xmyacl f-M && (getfacl f-M | grep -e "^mask:" -c | grep -q 0)
    CHECK_RESULT $? 0 0 "L$LINENO: -X No Pass" 
        
    ### -b ###
    (getfacl f-b | grep -e "^group:$gid:" -e "^mask::" -c | grep -q 0) \
        && setfacl -m g:$gid:rw,m::rx f-b \
        && (getfacl f-b | grep -e "^group:$gid:rw-" -e "^mask::r-x" -c | grep -q 2) \
        && setfacl -b f-b \
        && (getfacl f-b | grep -e "^group:$gid:" -e "^mask::" -c | grep -q 0) 
    CHECK_RESULT $? 0 0 "L$LINENO: -b No Pass"
    
    ### --set ###
    (getfacl f-set | grep -qe "^user::rw-$ -e "^group::r--$ -e "^other::r--$") \
        && setfacl --set u::rw,g::rw,o::rw f-set \
        && (getfacl f-set | grep -qe "^user::rw-$ -e "^group::rw-$ -e "^other::rw-$")
    CHECK_RESULT $? 0 0 "L$LINENO: --set No Pass" 

    ### --set-file ###
    cat <<EOF >acl
u::rw
g::rw
o::rw
EOF
   [[ $? == 0 ]] && (getfacl f-set-file | grep -qe "^user::rw-$ -e "^group::r--$ -e "^other::r--$") \
        && setfacl --set-file=acl f-set-file\
        && (getfacl f-set-file | grep -qe "^user::rw-$ -e "^group::rw-$ -e "^other::rw-$")
    CHECK_RESULT $? 0 0 "L$LINENO: --set-file No Pass" 

    ### --mask ###
    setfacl -m m::wx f && (getfacl f | grep -qe "^mask::-wx$") \
        && setfacl --mask -m m::- f && (getfacl f | grep -qe "^mask::r--$")
    CHECK_RESULT $? 0 0 "L$LINENO: --mask No Pass" 

    ### -n ###
    setfacl -m m::wx f-n && (getfacl f-n | grep -qe "^mask::-wx$") \
        && setfacl -n -m m::- f-n && (getfacl f-n | grep -qe "^mask::---")
    CHECK_RESULT $? 0 0 "L$LINENO: -n No Pass" 

    ### -d ###
    (getfacl dir/subdir | grep -e "^default:" -c | grep -q 0) \
        && setfacl -d -m user:${uid}:rwx dir/subdir \
        && (getfacl dir/subdir | grep -qe "^default:" -c)
    CHECK_RESULT $? 0 0 "L$LINENO: -d No Pass" 

    ### -k ###
    setfacl -k dir/subdir \
        && (getfacl dir/subdir | grep -e "^default:" -c | grep -q 0)
    CHECK_RESULT $? 0 0 "L$LINENO: -k No Pass" 
    
    ### -R ###
    (getfacl -R dir2 | grep -e "^mask::" -c | grep -q 0) \
        && setfacl -R -m m::rw dir2 && (getfacl -R dir2  | grep -e "^mask::rw-" -c | grep -q 2)
    CHECK_RESULT $? 0 0 "L$LINENO: -m No Pass" 
    
    ### -L ###
    (getfacl factual | grep -e "^mask::" -c | grep -q 0) \
        && setfacl -L -m m::rx filelink && (getfacl factual | grep -qe "^mask::r-x")
    CHECK_RESULT $? 0 0 "L$LINENO: -L No Pass" 


    ### -P ###
    setfacl -P -m m::- filelink && (getfacl factual | grep -qe "^mask::r-x")
    CHECK_RESULT $? 0 0 "L$LINENO: -P No Pass" 

    ### --restore ###
    cat <<EOF >acl
# file: dir2
# owner: root
# group: root
user::rwx
group::r-x
other::r-x

# file: dir2/subdir2
# owner: root
# group: root
user::rwx
group::r-x
other::r-x

EOF
    read -d '' myaclold < <(getfacl -R dir2)
    read -d '' myacl < <(cat acl)
    [[  x$myaclold != x && x$myacl != x && $myaclold != $myacl ]] \
        && setfacl --restore acl \
        && { read -d '' myaclnew < <(getfacl -R dir2); [[ x$$myaclnew != x && $myaclnew == $myacl ]]; }
    CHECK_RESULT $? 0 0 "L$LINENO: --restore No Pass" 
    
    ### --test ###
    (getfacl f-test | grep -e "^mask::" -c | grep -q 0) \
        && setfacl --test -m m::- f-test && (getfacl f-test | grep -e "^mask::" -c | grep -q 0)
    CHECK_RESULT $? 0 0 "L$LINENO: -test No Pass" 
    
    ### -v ###
    setfacl -v | grep -qe "^setfacl [[:digit:]]"
    CHECK_RESULT $? 0 0 "L$LINENO: -v No Pass"
    
    ### -h ###
    setfacl -h | grep -qe "^Usage: setfacl" 
    CHECK_RESULT $? 0 0 "L$LINENO: -h No Pass"
    
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    
    DNF_REMOVE 
    rm -rf dir dir2 acl filelink $myfilelist
    
    LOG_INFO "End to restore the test environment."
}

main "$@"
