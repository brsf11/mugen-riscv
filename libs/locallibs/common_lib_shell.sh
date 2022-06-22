#!/usr/bin/bash
# Copyright (c) [2020] Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   lemon.higgins
#@Contact   	:   lemon.higgins@aliyun.com
#@Date      	:   2020-04-09 09:39:43
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   Public function
#####################################

function LOG_INFO() {
    printf "$(date +%Y-%m-%d\ %T)  $0  [ INFO  ]  %s\n" "$@"
}

function LOG_WARN() {
    printf "$(date +%Y-%m-%d\ %T)  $0  [ WARN  ]  %s\n" "$@"
}

function LOG_ERROR() {
    printf "$(date +%Y-%m-%d\ %T)  $0  [ ERROR ]  %s\n" "$@"
}

function SSH_CMD() {
    expect -v
    if [ $? -ne 0 ]; then
        LOG_ERROR "System not support expect, not support SSH_CMD"
        return 1
    fi
    cmd=$1
    remoteip=$2
    remotepasswd=${3-openEuler12#$}
    remoteuser=${4-root}
    timeout=${5-300}
    connport=${6-22}

    bash ${OET_PATH}/libs/locallibs/sshcmd.sh -c "$cmd" -i "$remoteip" -u "$remoteuser" -p "$remotepasswd" -t "$timeout" -o "$connport"
    ret=$?
    test $ret -ne 0 && LOG_ERROR "Failed in remote CMD operation:$ret"
    return $ret
}

function SSH_SCP() {
    expect -v
    if [ $? -ne 0 ]; then
        LOG_ERROR "System not support expect, not support SSH_SCP"
        return 1
    fi
    src=$1
    dest=$2
    remotepasswd=${3-openEuler12#$}
    connport=${4-22}

    bash ${OET_PATH}/libs/locallibs/sshscp.sh -p "$remotepasswd" -o "$connport" -s "$src" -d "$dest"
    ret=$?
    test $ret -ne 0 && LOG_ERROR "Failed in remote SCP operation: $ret"
    return $ret
}

function P_SSH_CMD() {
    LOG_ERROR "python3 not find, not support P_SSH_CMD"
    exit 1
}

function SFTP() {
    LOG_ERROR "python3 not find, not support SFTP"
    exit 1
}

function TEST_NIC() {
    LOG_ERROR "python3 not find, not support TEST_NIC"
    exit 1
}

function TEST_DISK() {
    LOG_ERROR "python3 not find, not support TEST_DISK"
    exit 1
}

function DNF_INSTALL() {
    dnf --version
    if [ $? -ne 0 ]; then
        LOG_ERROR "system not find have dnf, not support DNF_INSTALL"
        return 1
    fi
    __pkg_list=$1
    node=${2-1}
    if [ -z "${__pkg_list}" ]; then
        LOG_ERROR "Wrong parameter."
        exit 1
    fi

    location=$[ "NODE"$node"_LOCATION" ]
    if [[ location == "local" ]]; then
        reponames=$(grep '^\[.*\]' /etc/yum.repos.d/*.repo | tr -d [] | sed -e ':a;N;$!ba;s/\n/ /g')
        mapfile -t __install_pkgs < <(dnf --assumeno install ${__pkg_list[*]} 2>&1 | grep -wE "${reponames// /|}" | grep -wE "$(uname -m)|noarch" | awk '{print $1}')
        dnf -y install ${__pkg_list[*]}

        if ! dnf -y install ${__pkg_list[*]}; then
            LOG_ERROR "pkg_list:${__pkg_list[*]} install failed."
            exit 1
        fi
    else
        remoteIp=$[ "NODE"$node"_IPV4" ]
        password=$[ "NODE"$node"_PASSWORD" ]
        ssh_port=$[ "NODE"$node"_SSH_PORT" ]
        remoteUser=$[ "NODE"$node"_USER" ]
        cmd="dnf -y install ${__pkg_list[*]}"

        ret=SSH_CMD "$cmd" "$remoteIp" "$password" "$remoteUser" 300 "$ssh_port"

        if [ ret -ne 0 ]; then
            LOG_ERROR "pkg_list:${__pkg_list[*]} install failed."
            exit 1
        fi
    fi

    __installed_pkgs+=" ${__install_pkgs[*]}"

    return 0
}

function DNF_REMOVE() {
    dnf --version
    if [ $? -ne 0 ]; then
        LOG_ERROR "system not find have dnf, not support DNF_INSTALL"
        return 1
    fi

    node=${1-1}
    __pkg_list=${2-""}
    mode=${3-0}

    if [[ -z "$__installed_pkgs" && -z "$pkg_list" ]]; then
        LOG_WARN "no thing to do."
        return 0
    fi

    [ $mode -ne 0 ] && {
        tmpf=$__installed_pkgs
        __installed_pkgs=""
    }

    node_number=$(env | grep -E "NODE[0-9]+=" | wc -l)

    if [ "$node" -eq 0 ]; then
        for node_id in $(seq 1 $node_number); do
            location=$[ "NODE"$node_id"_LOCATION" ]
            if [[ location == "local" ]]; then
                if ! dnf -y remove ${__installed_pkgs[*]} ${__pkg_list[*]}; then
                    LOG_ERROR "pkg_list:${__installed_pkgs[*]} ${__pkg_list[*]} remove failed."
                    exit 1
                fi
            else
                remoteIp=$[ "NODE"$node_id"_IPV4" ]
                password=$[ "NODE"$node_id"_PASSWORD" ]
                ssh_port=$[ "NODE"$node_id"_SSH_PORT" ]
                remoteUser=$[ "NODE"$node_id"_USER" ]
                cmd="dnf -y remove ${__installed_pkgs[*]} ${__pkg_list[*]}"

                ret=SSH_CMD "$cmd" "$remoteIp" "$password" "$remoteUser" 300 "$ssh_port"

                if [ ret -ne 0 ]; then
                    LOG_ERROR "pkg_list:${__pkg_list[*]} remove failed."
                    exit 1
                fi
            fi
        done
    else
        location=$[ "NODE"$node"_LOCATION" ]
        if [[ location == "local" ]]; then
            if ! dnf -y remove ${__installed_pkgs[*]} ${__pkg_list[*]}; then
                LOG_ERROR "pkg_list:${__installed_pkgs[*]} ${__pkg_list[*]} remove failed."
                exit 1
            fi
        else
            remoteIp=$[ "NODE"$node"_IPV4" ]
            password=$[ "NODE"$node"_PASSWORD" ]
            ssh_port=$[ "NODE"$node"_SSH_PORT" ]
            remoteUser=$[ "NODE"$node"_USER" ]
            cmd="dnf -y remove ${__installed_pkgs[*]} ${__pkg_list[*]}"

            ret=SSH_CMD "$cmd" "$remoteIp" "$password" "$remoteUser" 300 "$ssh_port"

            if [ ret -ne 0 ]; then
                LOG_ERROR "pkg_list:${__pkg_list[*]} remove failed."
                exit 1
            fi
        fi
    fi

    [ $mode -ne 0 ] && {
        __installed_pkgs=$tmpf
    }
}

function IS_FREE_PORT() {
    port=$1
    ip=${2-""}
    if [ -n $ip ]; then
        ifconfig | grep $ip
        if [ $? -ne 0 ]; then
            LOG_ERROR "check ip not local ip, not support IS_FREE_PORT"
            exit 1
        fi
    fi

    get_num=$(netstat -nltp | grep $port | wc -l)
    if [ $get_num -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

function GET_FREE_PORT() {
    ip=${1-""}
    start_port=${2-1000}
    end_port=${3-10000}
    if [ -n $ip ]; then
        ifconfig | grep $ip
        if [ $? -ne 0 ]; then
            LOG_ERROR "check ip not local ip, not support GET_FREE_PORT"
            exit 1
        fi
    fi
    
    range=`expr $end_port - $start_port`
    for i in seq 100; do
        rand=`expr$RANDOM % $range`
        new_port=`expr $start_port + $rand`
        check=IS_FREE_PORT new_port
        if [ $check -eq 0 ]; then
            return $new_port
        fi
    done

    return 0
}

function SLEEP_WAIT() {
    wait_time=${1-1}
    cmd=$2
    sleep_time=0

    waiteType=${wait_time: -1}
    waitesend=${wait_time:0:-1}
    case $waiteType in
    m)
        waitesend=`expr $waitesend * 60`
        ;;
    h)
        waitesend=`expr $waitesend * 3600`
        ;;
    s)
        ;;
    [0-9])
        waitesend=$wait_time
        ;;
    *)
        LOG_ERROR "only support h m s"
        ;;
    esac

    while [ $sleep_time -lt $waitesend ]; do
        sleep 1
        if [ -n "$cmd" ]; then
            if $cmd; then
                return 0
            fi
        fi
        ((sleep_time++))
    done
}

function REMOTE_REBOOT_WAIT() {
    node=${1-2}
    waittime=${2-""}

    remoteip=$[ "NODE"$node"_IPV4" ]
    remotepasswd=$[ "NODE"$node"_PASSWORD" ]
    ssh_port=$[ "NODE"$node"_SSH_PORT" ]
    remoteuser=$[ "NODE"$node"_USER" ]

    count=0

    if [[ "$waittime"x == ""x ]]; then
        if [[ "$(dmidecode -s system-product-name)" =~ "KVM" ]]; then
            waittime=300
        else
            waittime=600
        fi
    fi

    while [ $count -lt $waittime ]; do
        if ping -c 1 $remoteip; then
            if SSH_CMD "echo '' > /dev/null 2>&1" $remoteip $remotepasswd $remoteuser; then
                return 0
            else
                SLEEP_WAIT 1
                ((count++))
            fi
        else
            SLEEP_WAIT 1
            ((count++))
        fi
    done

    return 1
}

function REMOTE_REBOOT() {
    node=${1-2}
    waittime=${2-""}

    remoteip=$[ "NODE"$node"_IPV4" ]
    remotepasswd=$[ "NODE"$node"_PASSWORD" ]
    ssh_port=$[ "NODE"$node"_SSH_PORT" ]
    remoteuser=$[ "NODE"$node"_USER" ]

    if SSH_CMD "reboot" $remoteip $remotepasswd $remoteuser; then
        LOG_ERROR "do reboot fail"
        exit 1
    else
        REMOTE_REBOOT_WAIT $node $waitetime
    fi
}
