#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# ##############################################################################################################
# @Author    :   zhanglu626
# @Contact   :   m18409319968@163.com
# @Date      :   2022/01/18
# @License   :   Mulan PSL v2
# @Desc      :   Many of the innuendo parameters and type information used to describe the popularity of GeoTiff
# ##############################################################################################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    DNF_INSTALL libgeotiff
    mkdir zl
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    makegeo
    test -f newgeo.tif
    CHECK_RESULT $? 0 0 "The tif file is not generated"
    listgeo newgeo.tif >zl/new.geo
    test -f zl/new.geo
    CHECK_RESULT $? 0 0 "The geo file is not generated"
    listgeo -d newgeo.tif 2>&1 | grep ".0000000"
    CHECK_RESULT $? 0 0 "Use the decimal point instead of the DMS to report corner failures"
    listgeo -proj4 newgeo.tif 2>&1 | grep "d 0' 0.00"
    CHECK_RESULT $? 0 0 "Report project.4 equivalent projection definition failed"
    listgeo -no_norm newgeo.tif >zl/zlaaa
    A=$(grep -c "Corner Coordinates" zl/zlaaa)
    if [ "$A" -eq 0 ]; then
        echo "True"
    else
        exit 1
    fi
    CHECK_RESULT $? 0 0 "Do not report a failure to normalize parameter values"
    listgeo -tfw newgeo.tif 2>&1 | grep "World file written"
    CHECK_RESULT $? 0 0 "The tfw file is not generated"
    geotifcp newgeo.tif zl/newgeo1.tiff
    file zl/newgeo1.tiff 2>&1 | grep "TIFF image data"
    CHECK_RESULT $? 0 0 "This file is not an image file"
    touch zl/newgeo2.tiff
    applygeo zl/new.geo zl/newgeo2.tiff
    file zl/newgeo2.tiff 2>&1 | grep "TIFF image data"
    CHECK_RESULT $? 0 0 "This file is not an image file"
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    DNF_REMOVE
    rm -rf newgeo.tif newgeo.tfw zl
    LOG_INFO "Finish environment cleanup."
}

main $@
