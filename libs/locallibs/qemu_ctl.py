# -*- coding: utf-8 -*-
"""
 Copyright (c) [2021] Huawei Technologies Co.,Ltd.ALL rights reserved.
 This program is licensed under Mulan PSL v2.
 You can use it according to the terms and conditions of the Mulan PSL v2.
          http://license.coscl.org.cn/MulanPSL2
 THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
 EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
 MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 See the Mulan PSL v2 for more details.

 @Author  : saarloos
 @email   : 9090-90-90-9090@163.com
 @Date    : 2022-05-20 15:41:00
 @License : Mulan PSL v2
 @Version : 1.0
 @Desc    : qemu的启动和停止控制
"""

import subprocess
import json
import os
import sys
import argparse
import time
import threading
import signal
import paramiko

SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))
sys.path.append(SCRIPT_PATH)
import mugen_log

OET_PATH = os.environ.get("OET_PATH")
if OET_PATH is None:
    mugen_log.logging("ERROR", "环境变量：OET_PATH不存在，请检查mugen框架.")
    sys.exit(1)

save_path = OET_PATH.rstrip("/") + "/" + "conf/qemu_info.json"
os.makedirs(OET_PATH.rstrip("/") + "/" + "conf", exist_ok=True)

MAX_QEMU_NUM = 253

option_wait_time = 60

json_keys_help = "json key support:\n" \
    "    qemu_type: qemu type, support aarch64 and arm, default aarch64 \n" \
    "    machine: qemu machine type, default virt-4.0 \n" \
    "    cpu: qemu cpu type, for aarch64 default cortex-a57, arm default cortex-a15\n" \
    "    qemu_ip: qemu ipv4 address, if have more then one qemu config,\n" \
    "             all config qemu_ip must in same subnet, default 192.168.10.x\n" \
    "    qemu_ssh_port: qemu ssh port had set in system image, default 22\n" \
    "    host_ip: host br0 ipv4 address, if have more then one qemu config,\n" \
    "             all config host_ip must same\n" \
    "    user: qemu login root, default root\n" \
    "    passwd: qemu login passwd, default openEuler@123\n" \
    "    kernal_img_path: kernal img file full path\n" \
    "    initrd_path: kernal img file full path\n" \
    "    memory_size: memory size (MB), default 2048MB\n" \
    "    excess_qemu_option: excess qemu option\n"

def qemu_support():
    print(json_keys_help)

def qemu_load_qemu_info():
    qemu_pids = {}
    if not os.path.exists(save_path):
        return qemu_pids

    try:
        f = open(save_path, "r")
        qemu_pids = json.load(f)
        f.close()
    except Exception as e:
        mugen_log.logging("WARN", "some thing fail in loading qemu pid file")
        print(e)
        qemu_pids = {}
    finally:
        f.close()

    return qemu_pids

def qemu_stop():
    qemu_pids = qemu_load_qemu_info()
    if "start_pids" not in qemu_pids.keys():
        mugen_log.logging("WARN", "no pid infos found")
        if os.path.exists(save_path):
            os.remove(save_path)
        return

    for one_pid in qemu_pids["start_pids"]:
        mugen_log.logging("INFO", "kill pid : %d qemu"%one_pid)
        try:
            os.kill(one_pid, signal.SIGKILL)
        except ProcessLookupError as e:
            mugen_log.logging("WARN", "kill %d fail, %s"%(one_pid, e))
    if os.path.exists(save_path):
        os.remove(save_path)

def qemu_start_updata_qemu_rem(all_sub):
    qemu_pids = qemu_load_qemu_info()

    if "start_pids" not in qemu_pids.keys():
        qemu_pids["start_pids"] = []

    for sub in all_sub:
        qemu_pids["start_pids"].append(sub.pid)

    mugen_log.logging("INFO", "all start qemu pid: %s"%(" ".join([str(x) for x in qemu_pids["start_pids"]])))

    with open(save_path, "w") as f:
        f.write(json.dumps(qemu_pids, indent=4))
        mugen_log.logging("INFO", "qemu pids saved")

def qemu_start_stop_all(sub_list):
    for one in sub_list:
        one.terminate()
        one.kill()

is_qemu_ok = False

def qemu_start_wait_start(sub_list, wait_time = 60):
    global is_qemu_ok
    i = 0
    while i < wait_time:
        time.sleep(1)
        if is_qemu_ok:
            break
        i += 1
    if not is_qemu_ok:
        qemu_start_stop_all(sub_list)

def qemu_start_make_cmd(finally_config, i, br_name):
    run_cmd = []
    run_cmd.append("qemu-system-%s"%finally_config["qemu_type_list"][i])
    run_cmd.append("-M")
    run_cmd.append(finally_config["machine_list"][i])
    run_cmd.append("-cpu")
    run_cmd.append(finally_config["cpu_list"][i])
    run_cmd.append("-m")
    run_cmd.append(finally_config["memory_size_list"][i])
    run_cmd.append("-kernel")
    run_cmd.append(finally_config["kernal_img_path_list"][i])
    run_cmd.append("-initrd")
    run_cmd.append(finally_config["initrd_path_list"][i])
    run_cmd.append("-nographic")
    run_cmd.append("-device")
    run_cmd.append("virtio-net-device,netdev=tap0,mac=%s"%finally_config["qemu_mac_list"][i])
    run_cmd.append("-netdev")
    run_cmd.append("bridge,id=tap0,br=%s"%br_name)

    return run_cmd

def qemu_start_wait_output(wait_output, one_sub, all_sub, check_location = -1, wait_time = 60):
    global is_qemu_ok
    is_qemu_ok = False
    threading.Thread(target=qemu_start_wait_start, args=[all_sub, wait_time]).start()

    line = one_sub.stdout.readline()
    while one_sub.poll() is None:
        localtion = line.find(wait_output)
        if (check_location < 0 and localtion >= 0) or (check_location >= 0 and localtion == check_location):
            is_qemu_ok = True
            break

        line = one_sub.stdout.readline()

    return is_qemu_ok

check_login_str = ""
check_sshd_start_cmd = ""
start_sshd_cmd = ""

def qemu_start_subprocess(finally_config, br_name):
    global check_login_str
    global check_sshd_start_cmd
    global start_sshd_cmd
    global option_wait_time

    sub_list = []
    i = 0
    while i < finally_config["count"]:
        run_cmd = qemu_start_make_cmd(finally_config, i, br_name)
        if finally_config["excess_qemu_option_list"][i] != "":
            run_cmd.extend(finally_config["excess_qemu_option_list"][i].split())
        mugen_log.logging("INFO", "will run : %s"%" ".join(run_cmd))
        one_sub = subprocess.Popen(run_cmd, stdin=subprocess.PIPE,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8")
        time.sleep(1)
        if one_sub.poll() is not None:
            output_out, output_err = one_sub.communicate()
            mugen_log.logging("ERROR", "start qemu %d fail, retcode %d, output:\n %s \n %s"%(i, one_sub.returncode, output_out, output_err))
            qemu_start_stop_all(sub_list)
            sys.exit(1)

        sub_list.append(one_sub)

        one_sub.stdin.write("\n")
        one_sub.stdin.flush()

        check_wait = qemu_start_wait_output(check_login_str, one_sub, sub_list, wait_time=option_wait_time)
        if not check_wait:
            mugen_log.logging("ERROR", "start qemu %d fail, wait time too long"%i)
            sys.exit(1)

        one_sub.stdin.write(finally_config["user_list"][i] + "\n")
        one_sub.stdin.flush()
        time.sleep(1)
        one_sub.stdin.write(finally_config["passwd_list"][i] + "\n")
        one_sub.stdin.flush()
        time.sleep(1)
        one_sub.stdin.write(finally_config["passwd_list"][i] + "\n")
        one_sub.stdin.flush()
        time.sleep(1)
        one_sub.stdin.write("\n")
        one_sub.stdin.flush()
        time.sleep(1)
        one_sub.stdin.write("echo 'login qemu'" + "\n")
        one_sub.stdin.flush()
        check_wait = qemu_start_wait_output("login qemu", one_sub, sub_list, 0, wait_time=option_wait_time)
        if not check_wait:
            mugen_log.logging("ERROR", "start qemu %d fail, not login qemu"%i)
            sys.exit(1)
        one_sub.stdin.write("ifconfig eth0 %s up\n"%finally_config["qemu_ip_list"][i] + "\n")
        one_sub.stdin.flush()
        time.sleep(1)
        one_sub.stdin.flush()

        run_start_sshd_cmd = ""
        if start_sshd_cmd != "" and check_sshd_start_cmd != "":
            run_start_sshd_cmd = "%s || %s\n"%(check_sshd_start_cmd, start_sshd_cmd)
        elif start_sshd_cmd != "":
            run_start_sshd_cmd = "%s\n"%(start_sshd_cmd)

        check_run_start_sshd_cmd = ""
        if check_sshd_start_cmd != "":
            check_run_start_sshd_cmd = "for i in {1..60}; "\
                                       "do "\
                                       "if %s; then "\
                                       "echo 'check run sshd ok'; "\
                                       "break; "\
                                       "else "\
                                       "sleep 1; "\
                                       "fi; "\
                                       "done\n"%(check_sshd_start_cmd)

        if run_start_sshd_cmd != "":
            mugen_log.logging("INFO", "will run cmd in qemu to start sshd: %s"%run_start_sshd_cmd)
            one_sub.stdin.write(run_start_sshd_cmd + "\n")
            one_sub.stdin.flush()
            time.sleep(1)

        if check_run_start_sshd_cmd != "":
            mugen_log.logging("INFO", "will run cmd in qemu to check sshd start: %s"%check_run_start_sshd_cmd)
            one_sub.stdin.write(check_run_start_sshd_cmd + "\n")
            one_sub.stdin.flush()
            check_wait = qemu_start_wait_output("check run sshd ok", one_sub, sub_list, 0, wait_time=option_wait_time)
            if not check_wait:
                mugen_log.logging("ERROR", "start qemu sshd %d fail"%i)
                sys.exit(1)

        one_sub.stdin.write("echo 'end set qemu'" + "\n")
        one_sub.stdin.flush()
        check_wait = qemu_start_wait_output("end set qemu", one_sub, sub_list, 0, wait_time=option_wait_time)
        if not check_wait:
            mugen_log.logging("ERROR", "start qemu %d fail, check end output fail"%i)
            sys.exit(1)

        check_sub = subprocess.Popen(["ping", finally_config["qemu_ip_list"][i], "-c", "3"],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8")
        check_out, check_error = check_sub.communicate()
        if check_out.lower().find("error") >= 0 or check_error.lower().find("error") >= 0:
            mugen_log.logging("ERROR", "set qemu %d ip fail"%i)
            qemu_start_stop_all(sub_list)
            sys.exit(1)

        i += 1

    return sub_list

def qemu_start_check_config_keys(one_config, all_key:list):
    support_keys = ["qemu_type", "user", "passwd", "machine", "cpu", "qemu_ip", "host_ip",
        "kernal_img_path", "initrd_path", "memory_size", "excess_qemu_option", "qemu_ssh_port"]
    must_keys = ["kernal_img_path", "initrd_path"]

    if not all(key in all_key for key in must_keys):
        mugen_log.logging("ERROR", "json must have 'qemu_type', 'kernal_img_path', 'initrd_path' keys")
        sys.exit(1)

    for key in all_key:
        if key not in support_keys:
            mugen_log.logging("WARN", "qemu config key %s not support"%key)
        if "qemu_type" not in all_key:
            continue
        qemu_type = one_config["qemu_type"]
        if qemu_type != "aarch64" and qemu_type != "arm":
            mugen_log.logging("WARN", "qemu type not default support, please make sure qemu-system-%s installed"%qemu_type)
            # qemu_support()
            # sys.exit(1)

def qemu_start_get_begin_ip_num(creat_num):
    qemu_pids = qemu_load_qemu_info()
    ret_num = 2

    if "start_pids" in qemu_pids.keys():
        ret_num = len(qemu_pids["start_pids"]) + 2

    if creat_num > MAX_QEMU_NUM - (ret_num - 2):
        mugen_log.logging("ERROR", "Can max creat qemu num is %d, had creat %d can't creat more %d"%(MAX_QEMU_NUM, ret_num, creat_num))
        sys.exit(1)

    return ret_num

def qemu_start_get_finally_config(all_config):
    finally_config = {
        "host_ip" : "",
        "count" : 0,
        "qemu_type_list" : [],
        "user_list" : [],
        "passwd_list" : [],
        "machine_list" : [],
        "cpu_list" : [],
        "qemu_ip_list" : [],
        "qemu_mac_list" : [],
        "qemu_ssh_port_list" : [],
        "kernal_img_path_list" : [],
        "initrd_path_list" : [],
        "memory_size_list" : [],
        "excess_qemu_option_list" : [],
    }
    default_typ_cpu_map = {
        "aarch64" : "cortex-a57",
        "arm" : "cortex-a15",
    }

    ip_begin = qemu_start_get_begin_ip_num(len(all_config))
    need_set_host_ip = True
    for one_config in all_config:
        all_key = one_config.keys()
        qemu_start_check_config_keys(one_config, all_key)

        qemu_type = "aarch64" if "qemu_type" not in all_key else one_config["qemu_type"]
        user = "root" if "user" not in all_key else one_config["user"]
        passwd = "openEuler@123" if "passwd" not in all_key else one_config["passwd"]
        machine = "virt-4.0" if "machine" not in all_key else one_config["machine"]
        cpu = default_typ_cpu_map[qemu_type] if "cpu" not in all_key else one_config["cpu"]
        kernal_img_path = one_config["kernal_img_path"]
        initrd_path = one_config["initrd_path"]
        excess_qemu_option = "" if "excess_qemu_option" not in all_key else one_config["excess_qemu_option"]
        memory_size = "2048M" if "memory_size" not in all_key else one_config["memory_size"] + "M"
        qemu_ip = "192.168.10.%d"%ip_begin if "qemu_ip" not in all_key else one_config["qemu_ip"]
        if "qemu_ip" in all_key:
            need_set_host_ip = False
        qemu_mac = "52:54:00:12:34:%02x"%ip_begin
        qemu_ssh_port = "22" if "qemu_ssh_port" not in all_key else one_config["qemu_ssh_port"]
        ip_begin += 1

        finally_config["qemu_type_list"].append(qemu_type)
        finally_config["host_ip"] = "" if "host_ip" not in all_key else one_config["host_ip"]
        finally_config["user_list"].append(user)
        finally_config["passwd_list"].append(passwd)
        finally_config["machine_list"].append(machine)
        finally_config["cpu_list"].append(cpu)
        finally_config["qemu_ip_list"].append(qemu_ip)
        finally_config["qemu_mac_list"].append(qemu_mac)
        finally_config["qemu_ssh_port_list"].append(qemu_ssh_port)
        finally_config["kernal_img_path_list"].append(kernal_img_path)
        finally_config["initrd_path_list"].append(initrd_path)
        finally_config["memory_size_list"].append(memory_size)
        finally_config["excess_qemu_option_list"].append(excess_qemu_option)
        finally_config["count"] += 1

    if need_set_host_ip :
        finally_config["host_ip"] = "192.168.10.1"
    else:
        if finally_config["host_ip"] == "":
            mugen_log.logging("ERROR", "Must set host_ip if had set qemu_ip")
            sys.exit(1)
    return finally_config

def qemu_start_wait_ssh_connect(ip, port, user, password, wait_time = 60):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy)
    wait_i = 0
    while wait_i < wait_time:
        try:
            ssh.connect(ip, port, user, password)
            ssh.close()
            break
        except paramiko.ssh_exception.NoValidConnectionsError as e:
            mugen_log.logging("INFO", "wait 1 sec for ssh connect, - out %s"%e)
            time.sleep(1)
            wait_i += 1

def qemu_start_config_conf(finally_config, put_all):
    global option_wait_time
    i = 0
    copy_string = ""
    if put_all:
        copy_string = "--put_all"
    while i < finally_config["count"]:
        remote_str = ""
        # only first qemu need set run_remote
        if i == 0:
            remote_str = "--run_remote"
        # some time may wait some time to connect ssh, this is for it
        qemu_start_wait_ssh_connect(finally_config["qemu_ip_list"][i],
                                    finally_config["qemu_ssh_port_list"][i],
                                    finally_config["user_list"][i],
                                    finally_config["passwd_list"][i],
                                    option_wait_time)
        cmd = "python3 %s/libs/locallibs/write_conf.py --ip '%s' --password '%s' --port '%s' --user '%s' %s %s"%(
              OET_PATH,
              finally_config["qemu_ip_list"][i],
              finally_config["passwd_list"][i],
              finally_config["qemu_ssh_port_list"][i],
              finally_config["user_list"][i],
              remote_str,
              copy_string)
        mugen_log.logging("INFO", "run cmd: %s"%cmd)
        exitcode = subprocess.getstatusoutput(cmd)
        if exitcode[0] != 0:
            mugen_log.logging("ERROR", "config qemu %d conf file fail, return code %d, output: %s"%(i, exitcode[0], exitcode[1]))
            return exitcode

        i += 1
    return 0

def qemu_start_copy_libs(finally_config):
    i = 0
    while i < finally_config["count"]:
        cmd = "python3 %s/libs/locallibs/sftp.py put --ip '%s' --password '%s' --port '%s' --user '%s' --node '-1' --localdir '%s' --remotedir '%s'"%(
              OET_PATH,
              finally_config["qemu_ip_list"][i],
              finally_config["passwd_list"][i],
              finally_config["qemu_ssh_port_list"][i],
              finally_config["user_list"][i],
              "%s/libs/"%OET_PATH,
              "/mugen_re/")
        mugen_log.logging("INFO", "run cmd: %s"%cmd)
        exitcode = subprocess.getstatusoutput(cmd)[0]
        if exitcode != 0:
            mugen_log.logging("ERROR", "copy base libs to qemu %d fail"%i)
            return exitcode

        i += 1
    return 0

def qemu_start(qemu_config, put_all, br_name):
    if type(qemu_config) is list:
        if len(qemu_config) == 0:
            mugen_log.logging("ERROR", "qemu config min num is 1")
            sys.exit(1)
        if len(qemu_config) > MAX_QEMU_NUM:
            mugen_log.logging("ERROR", "qemu config max support 243")
            sys.exit(1)
        for item in qemu_config:
            if type(item) is not dict:
                mugen_log.logging("ERROR", "qemu config json wrong")
                qemu_support()
                sys.exit(1)
        all_config = qemu_config
    elif type(qemu_config) is not dict:
        mugen_log.logging("ERROR", "qemu config json wrong")
        qemu_support()
        sys.exit(1)
    else:
        all_config = [qemu_config]

    finally_config = qemu_start_get_finally_config(all_config)
    if finally_config["host_ip"] != "":
        subprocess.run(["ifconfig", br_name, finally_config["host_ip"]])
    all_sub = qemu_start_subprocess(finally_config, br_name)
    if qemu_start_config_conf(finally_config, put_all) != 0:
        qemu_start_stop_all(all_sub)
        sys.exit(1)
    if qemu_start_copy_libs(finally_config) != 0:
        qemu_start_stop_all(all_sub)
        sys.exit(1)
    qemu_start_updata_qemu_rem(all_sub)

def qemu_control(options, args):
    global check_login_str
    global check_sshd_start_cmd
    global start_sshd_cmd
    global option_wait_time

    config_file = args.config_file
    check_login_str = args.login_wait_str
    if check_login_str == "":
        check_login_str = "login:"
    put_all = args.put_all
    if (options == "stop" and config_file is not None):
        mugen_log.logging("ERROR", "stop no need config file")
        sys.exit(1)
    if (options == "start" and config_file is not None and not os.path.exists(config_file)):
        mugen_log.logging("ERROR", "config file no exists ")
        sys.exit(1)

    if (options == "stop"):
        return qemu_stop()

    if config_file is not None:
        try:
            f = open(config_file, "r")
            qemu_config = json.load(f)
        except Exception as e:
            mugen_log.logging("ERROR", "some thing fail in loading json file")
            print(e)
            qemu_config = None
        finally:
            f.close()
    else:
        qemu_config = {}
        if args.qemu_type is not None: qemu_config["qemu_type"] = args.qemu_type
        if args.user is not None: qemu_config["user"] = args.user
        if args.passwd is not None: qemu_config["passwd"] = args.passwd
        if args.machine is not None: qemu_config["machine"] = args.machine
        if args.cpu is not None: qemu_config["cpu"] = args.cpu
        if args.qemu_ip is not None: qemu_config["qemu_ip"] = args.qemu_ip
        if args.host_ip is not None: qemu_config["host_ip"] = args.host_ip
        if args.kernal_img_path is not None: qemu_config["kernal_img_path"] = args.kernal_img_path
        if args.initrd_path is not None: qemu_config["initrd_path"] = args.initrd_path
        if args.memory_size is not None: qemu_config["memory_size"] = args.memory_size
        if args.excess_qemu_option is not None: qemu_config["excess_qemu_option"] = args.excess_qemu_option
        if args.qemu_ssh_port is not None: qemu_config["qemu_ssh_port"] = args.qemu_ssh_port

    if qemu_config is None:
        sys.exit(1)

    if args.check_sshd_start_cmd is not None: check_sshd_start_cmd = args.check_sshd_start_cmd
    if args.start_sshd_cmd is not None: start_sshd_cmd = args.start_sshd_cmd
    if args.option_wait_time is not None: option_wait_time = args.option_wait_time

    return qemu_start(qemu_config, put_all, args.br_name)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="manual to this script")
    parser.add_argument('option', type=str, choices=['start', 'stop'], help = "start qemu or stop qemu")
    parser.add_argument('--put_all', action="store_true", help = "config all qemu before run test copy all test case to qemu")
    parser.add_argument('--br_name', type=str, help = "config qemu use br name", default="testbr0")
    parser.add_argument('--login_wait_str', type=str, help = "start qemu wait this string to input user name ", default="login:")
    parser.add_argument('--option_wait_time', type=int, help = "start qemu every option wait time (s)", default=60)
    parser.add_argument('--start_sshd_cmd', type=str, help = "start sshd commond, if set will run after ip setted")
    parser.add_argument('--check_sshd_start_cmd', type=str, help = "check start sshd commond, if set will run after ip setted")

    config_file_group = parser.add_argument_group("config_file_group")
    config_file_group.add_argument('--config_file', type=str, help = "start qemu config json file", default=None)

    config_param_group = parser.add_argument_group("config_param_group")
    config_param_group.add_argument('--qemu_type', type=str, help = "start qemu config qemu_type", default=None)
    config_param_group.add_argument('--user', type=str, help = "start qemu config user", default=None)
    config_param_group.add_argument('--passwd', type=str, help = "start qemu config passwd", default=None)
    config_param_group.add_argument('--machine', type=str, help = "start qemu config machine", default=None)
    config_param_group.add_argument('--cpu', type=str, help = "start qemu config cpu", default=None)
    config_param_group.add_argument('--qemu_ip', type=str, help = "start qemu config qemu_ip", default=None)
    config_param_group.add_argument('--host_ip', type=str, help = "start qemu config host_ip", default=None)
    config_param_group.add_argument('--kernal_img_path', type=str, help = "start qemu config kernal_img_path", default=None)
    config_param_group.add_argument('--initrd_path', type=str, help = "start qemu config initrd_path", default=None)
    config_param_group.add_argument('--memory_size', type=str, help = "start qemu config memory_size", default=None)
    config_param_group.add_argument('--excess_qemu_option', type=str, help = "start qemu config excess_qemu_option", default=None)
    config_param_group.add_argument('--qemu_ssh_port', type=str, help = "start qemu config qemu_ssh_port", default=None)
    args = parser.parse_args()

    if ((args.config_file is not None or
         args.option == "stop") and
        (args.qemu_type is not None or
         args.user is not None or
         args.passwd is not None or
         args.machine is not None or
         args.cpu is not None or
         args.qemu_ip is not None or
         args.host_ip is not None or
         args.kernal_img_path is not None or
         args.initrd_path is not None or
         args.memory_size is not None or
         args.excess_qemu_option is not None or
         args.qemu_ssh_port is not None )):
        mugen_log.logging("ERROR", "had config config file, do not add other param config")
        sys.exit(1)

    qemu_control(args.option, args)
