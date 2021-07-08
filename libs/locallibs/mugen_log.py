# -*- coding: utf-8 -*-
"""
 This program is licensed under Mulan PSL v2.
 You can use it according to the terms and conditions of the Mulan PSL v2.
          http://license.coscl.org.cn/MulanPSL2
 THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
 EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
 MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 See the Mulan PSL v2 for more details.
 @Author  : lemon-higgins
 @email   : lemon.higgins@aliyun.com
 @Date    : 2021-04-20 15:37:16
 @License : Mulan PSL v2
 @Version : 1.0
 @Desc    : 日志输出模板
"""


import sys
import time
import argparse


def logging(level, message):
    """日志打印模板

    Args:
        level ([str]): 日志等级
        message ([str]): 日志信息
    """
    level_list = ["INFO", "WARN", "DEBUG", "ERROR"]
    log_level = level.upper()

    if level.upper() not in level_list:
        sys.exit(1)

    if log_level in ["INFO", "WARN"]:
        log_level = level.upper() + " "
    sys.stderr.write(
        "%s - %s - %s\n"
        % (time.asctime(time.localtime(time.time())), log_level, message)
    )


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="manual to this script")
    parser.add_argument("--level", type=str, default="info")
    parser.add_argument(
        "--message", type=str, default="Developer does not write the log messages."
    )
    args = parser.parse_args()

    logging(args.level, args.message)
