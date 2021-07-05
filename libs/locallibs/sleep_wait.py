# -*- coding: utf-8 -*-
"""
# @Author : lemon-higgins
# @Date   : 2021-07-01 02:09:51
# @Email  : lemon.higgins@aliyun.com
# @License: Mulan PSL v2
# @Desc   : 命令执行超时
"""

import subprocess
import time
import os
import sys
import argparse

SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))
sys.path.append(SCRIPT_PATH)
import mugen_log


def sleep_wait(wait_time, cmd=None, mode=1):
    """等待命令执行时长

    Args:
        wait_time ([int]): 待定时间
        cmd ([str], optional): 执行的命令. Defaults to None.
        mode (int, optional): 命令执行等待模式. Defaults to 1.
    """
    if not cmd:
        time.sleep(wait_time)
        sys.exit(0)
    if cmd and mode == 1:
        try:
            output = subprocess.check_output(
                cmd,
                stderr=subprocess.STDOUT,
                timeout=int(wait_time),
                shell=True,
            )
            exitcode = 0
            print(output.decode("utf-8"))
        except subprocess.CalledProcessError as e:
            mugen_log.logging("error", "CallError ：" + e.output.decode("utf-8"))
            exitcode = e.returncode
        except subprocess.TimeoutExpired as e:
            mugen_log.logging("error", "Timeout : " + str(e))
            exitcode = 143
        except Exception as e:
            mugen_log.logging("error", "Unknown Error : " + str(e))
            exitcode = 1

        sys.exit(exitcode)

    if cmd and mode == 2:
        init = 0
        while init < wait_time:
            time.sleep(1)
            exitcode, output = subprocess.getstatusoutput(cmd)
            if exitcode == 0:
                print(output)
                sys.exit(0)
            elif init == wait_time:
                sys.exit(exitcode)

            init += 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="manual to this script")
    parser.add_argument("--time", type=str)
    parser.add_argument("--cmd", type=str)
    parser.add_argument("--mode", type=int, choices=[1, 2], default=1)
    args = parser.parse_args()

    sleep_wait(args.time, args.cmd, args.mode)
