/*Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
  This program is licensed under Mulan PSL v2.
  You can use it according to the terms and conditions of the Mulan PSL v2.
           http://license.coscl.org.cn/MulanPSL2
  THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
  EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
  MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
  See the Mulan PSL v2 for more details.*/

#include <stdio.h>
#include <unistd.h>

int main()
{
    FILE *fp;
    fp = fopen("output.txt", "w+");

    int i;
    for (i = 0; i <= 300; i++)
    {
        usleep(100000);
        fprintf(fp, "%d\n", i);
        fflush(fp);
    }

    fclose(fp);
    return 0;
}
