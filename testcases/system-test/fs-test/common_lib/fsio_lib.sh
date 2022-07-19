#!/usr/bin/bash
# Copyright (c) [2022] Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author        :   @meitingli
# @Contact       :   244349477@qq.com
# @Date          :   2020-10-15
# @License       :   Mulan PSL v2
# @Desc          :   Public function
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
export FS_TYPE="ext3 ext4 xfs"
export LANG=en_US.UTF-8

function CREATE_LV() {
    lvname=$1
    vggroup=$2
    lvcreate -n $lvname -L 0.5G $vggroup -y
}

function EXTEND_LV() {
    lvname=$1
    lvextend -L 3G $lvname -y
}

function REDUCE_LV() {
    lvname=$1
    lvreduce -L 0.1G $lvname -y
}

function CHANGE_LV() {
    vggroup=$1
    lvchange -p rw $lvname -y
}

function DELETE_LV() {
    lvname=$1
    lvremove $lvname -y
}

function CONCURRENCY_THREAD() {
    # $1: execution cmd
    # $2: execution time, default is 100
    start_time=$(date +%s)
    command=$1
    concurrency_num=${2-"100"}

    # Create fifo and exec
    [ -e /tmp/fd1 ] || mkfifo /tmp/fd1
    exec 3<>/tmp/fd1
    rm -rf /tmp/fd1
    for ((i = 0; i < 9; i++)); do
        echo ""
    done >&3
    count=1
    for j in $(seq 0 $concurrency_num); do
        read -u3
        {
            $command $count
            sleep 5
            echo "" >&3
        } &
        count=$(($count + 1))
    done
    wait
    end_time=$(date +%s)
    exec_time=$(expr $(($end_time - $start_time)))
    echo "Exectue $concurrency_num cmd for times: ""$exec_time"
    exec 3>&-
    exec 3<&-
}

function GET_CONSOLE() {
    qemu-kvm -m 4096 -smp 4 -machine virt,accel=kvm,gic-version=3 -cpu host -bios /usr/share/edk2/aarch64/QEMU_EFI.fd -serial file:testlog -hda /data/images/XX.qcow2
}

function CREATE_VG() {
    cur_date=$(date +%Y%m%d%H%M%S)
    free_disk=$(lsblk | grep disk | awk '{print $1}' | tail -n 1)
    disk_name="/dev/"$free_disk
    pvcreate $disk_name -f &>/dev/null
    if [[ "$?" -eq "0" ]]; then
        vggroup="test_vggroup"$cur_date
        vgcreate $vggroup $disk_name >/dev/null
    else
        vggroup=$(pvcreate $disk_name 2>&1 | grep "test_vggroup" | cut -d '"' -f 4)
    fi
    printf $vggroup
}

function CREATE_FS() {
    fs_type=${1-$FS_TYPE}
    cur_date=$(date +%Y%m%d%H%M%S)
    vggroup=$(CREATE_VG)
    count=1
    msg=$vggroup" "
    for fs in ${fs_type[@]}; do
        lvname="test_lv"$count$cur_date
        point="/tmp/point"$count$cur_date
        lvcreate -n $lvname -L 512M $vggroup -y >/dev/null
        mkfs -t $fs /dev/$vggroup/$lvname >/dev/null
        mkdir $point
        mount /dev/$vggroup/$lvname $point >/dev/null
        msg=$msg$point" "
        count=$(($count + 1))
    done
    echo $msg
}

function REMOVE_FS() {
    point_list=($1)
    for i in $(seq 0 $((${#point_list[@]} - 1))); do
        tmp=${point_list[$i]}
        [[ $tmp =~ "point" ]] && {
            lv=$(df -T | grep $tmp | awk '{print $1}')
            umount -f $tmp
            rm -rf $tmp
            DELETE_LV $lv
        }
    done
}

function REMOVE_VG() {
    vggroup=$1
    [[ "$vggroup" != "" ]] && {
        vgremove $vggroup -y
    }
    mounted=$(df -T | grep "test_vggroup" | awk '{print $7}')
    if [[ "$mounted" != "" ]]; then
        for m in $mounted; do
            umount $m
        done
        vggroup=$(df -T | grep "test_vggroup" | awk '{print $1}' | cut -d '-' -f 1 | cut -d '/' -f 4 | head -n 1)
        vgremove $vggroup -y
    fi

    lsblk | grep "test_vggroup" >/dev/null
    [[ "$?" -eq "0" ]] && {
        vggroup=$(lsblk | grep "test_vggroup" | awk '{print $1}' | head -n 1 | cut -d '-' -f 1)
        vggroup=${vggroup:2}
        vgremove $vggroup -y
    }
    rm -rf /tmp/point*
}

function GET_RANDOMNAME() {
    exp_len=$1
    j=0
    name=""
    for i in {a..z}; do
        ranList[$j]=$i
        j=$(($j + 1))
    done
    for i in {A..Z}; do
        ranList[$j]=$i
        j=$(($j + 1))
    done
    for i in {0..9}; do
        ranList[$j]=$i
        j=$(($j + 1))
    done

    for i in $(seq 1 $exp_len); do
        index=$(($RANDOM % $j))
        name=$name${ranList[$index]}
    done
    printf $name
}

function CREATE_LARGE_FILE() {
    dir=$1
    max_path_len=$(getconf PATH_MAX $dir)

    for i in $(seq 1 100); do
        text=$(GET_RANDOMNAME $max_path_len)
        echo $text >>$dir/testFile
    done
}

function SET_BKG_MONITOR() {
    tmp_point=$1
    top -d 2 >$tmp_point/cpu.log &
    iostat -d 2 >$tmp_point/iostat.log &
}

function CHECK_BKG_MONITOR() {
    tmp_point=$1
    cpu_line=$2
    io_line=$3
    free_disk=$(lsblk | grep disk | awk '{print $1}' | tail -n 1)
    top_pid=$(ps -ef | grep "top -d 2" | head -n 1 | awk '{print $2}')
    iostat_pid=$(ps -ef | grep "iostat -d 2" | head -n 1 | awk '{print $2}')
    kill -9 $top_pid $iostat_pid
    free_cpu=$(grep "Cpu" cpu.log | awk '{print $8}')
    read_io=$(grep $free_disk iostat.log | awk '{print $3}')
    wrtn_io=$(grep $free_disk iostat.log | awk '{print $4}')
    for var in ${free_cpu[@]}; do
        [[ $var -lt $cpu_line ]] && {
            return 1
        }
    done
    for var in ${read_io[@]}; do
        [[ $var -gt $io_line ]] && {
            return 1
        }
    done
    for var in ${wrtn_io[@]}; do
        [[ $var -gt $io_line ]] && {
            return 1
        }
    done

    return 0
}

function ssh_cmd_node() {
    cmd=$1
    SSH_CMD "$cmd" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
}

REMOVE_VG
