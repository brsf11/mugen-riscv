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
# @Author    :   shangyingjie
# @Contact   :   yingjie@isrc.iscas.ac.cn
# @Date      :   2022/2/4
# @License   :   Mulan PSL v2
# @Desc      :   Test tidy character encodings
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    DNF_INSTALL tidy
    DNF_INSTALL uchardet
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    # -raw
    # 不转换为实体而直接输出
    # For raw, Tidy will output values above 127 without translating them into entities.
    echo '&yen;' | tidy -raw | grep '¥'
    CHECK_RESULT $? 1 0 "Failed to use option: -raw"
    # -ascii
    # 用 ISO-8859-1 作为输入编码，用 US-ASCII 输出
    # 用 US-ASCII 输出,其实就是以实体标签名的形式进行输出
    # 通过 iconv 将字符转换为 ISO-8859-1 编码格式,再通过 tidy 处理
    echo '½' | iconv -f UTF-8 -t ISO-8859-1 | tidy -ascii | grep '&frac12;'
    CHECK_RESULT $? 0 0 "Failed to use option: -ascii"
    # -latin0
    # 用 ISO-8859-15 作为输入编码, US-ASCII 作为输出
    echo 'Š' | iconv -f UTF-8 -t ISO-8859-15 | tidy -latin0 | grep '&Scaron;'
    CHECK_RESULT $? 0 0 "Failed to use option: -latin0"
    # -latin1
    # 将 ISO-8859-1 作为输入和输出编码
    # 使用 uchardet 对输出结果的编码格式进行检查,ISO-8859-1 会被检出 WINDOWS-1252 的结果
    echo '½' | iconv -f UTF-8 -t ISO-8859-1 | tidy -f /dev/null -latin1 | grep '<body>' -A 1 --text | uchardet | grep 'WINDOWS-1252'
    CHECK_RESULT $? 0 0 "Failed to use option: -latin1"
    # -iso2022
    # 将 ISO-2022 作为输入和输出编码
    # 选用遵从 ISO 2022 规范的 ISO-2022-KR 作为编码
    echo '도깨비' | iconv -t ISO-2022-KR | tidy -iso2022 -f /dev/null | grep '<body>' -A 1 | uchardet | grep 'ISO-2022-KR'
    CHECK_RESULT $? 0 0 "Failed to use option: -iso2022"
    # -utf8
    # 将 UTF-8 作为输入和输出编码
    echo 'ε' | iconv -t UTF-8 | tidy -utf8 -f /dev/null | grep '<body>' -A 1 | uchardet | grep 'UTF-8'
    CHECK_RESULT $? 0 0 "Failed to use option: -utf8"
    # -mac
    #  用 MacRoman 作为输入编码, US-ASCII 作为输出编码
    echo '¶' | iconv -t MAC-CENTRALEUROPE | tidy -mac | grep '&para;'
    CHECK_RESULT $? 0 0 "Failed to use option: -mac"
    # -win1252
    # 用 Windows-1252 作为输入编码, US-ASCII 作为输出编码
    echo '§' | iconv -f UTF-8 -t WINDOWS-1252 | tidy -win1252 | grep '<body>' -A 1 | grep '&sect;'
    CHECK_RESULT $? 0 0 "Failed to use option: -win1252"
    # -ibm858
    # 用 IBM-858 作为输入编码, US-ASCII 作为输出编码
    echo '║' | iconv -f UTF-8 -t IBM858 | tidy -ibm858 | grep '<body>' -A 1 | grep '&boxV;'
    CHECK_RESULT $? 0 0 "Failed to use option: -ibm858"
    # -utf16le
    # 用 UTF-16LE 作为输入和输出编码
    echo 'Σ' | iconv -f UTF-8 -t UTF-16LE | tidy -utf16le -o ./tidied.html
    encguess ./tidied.html | grep 'UTF-16LE'
    CHECK_RESULT $? 0 0 "Failed to use option: -utf16le"
    # -utf16be
    # 用 UTF-16BE 作为输入和输出编码
    echo 'Σ' | iconv -f UTF-8 -t UTF-16BE | tidy -utf16be -o ./tidied.html
    encguess ./tidied.html | grep 'UTF-16BE'
    CHECK_RESULT $? 0 0 "Failed to use option: -utf16be"
    # -utf16
    # 用 UTF-16 作为输入和输出编码
    echo 'Σ' | iconv -f UTF-8 -t UTF-16 | tidy -utf16 -o ./tidied.html
    encguess ./tidied.html | grep 'UTF-16'
    CHECK_RESULT $? 0 0 "Failed to use option: -utf16"
    # -big5
    # 用 BIG-5 作为输入和输出编码
    # 使用 uchardet 检出结果为 WINDOWS-1252
    echo '好' | iconv -f UTF-8 -t BIG-5 | tidy -big5 | uchardet | grep 'WINDOWS-1252'
    CHECK_RESULT $? 0 0 "Failed to use option: -big5"
    # -shiftjis
    # 用 SHITFT-JIS 作为输入和输出编码
    # 使用 uchardet 检出结果为 WINDOWS-1252
    echo 'ｦ' | iconv -f UTF-8 -t SHIFT-JIS | tidy -shiftjis | uchardet | grep 'WINDOWS-1252'
    CHECK_RESULT $? 0 0 "Failed to use option: -shiftjis"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    DNF_REMOVE
    rm -f ./tidied.html
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
