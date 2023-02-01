# RISC-V-oE自动化测试结果分析脚本使用  
- RISC-V oE自动化测试结果分析脚本  
    - 用于自动解析qemu_test.py测试结果日志文件，生成统计结果和初步的错因分析   
## 使用方法  
- 依赖安装  
    - 依赖 ```python3```  
- 使用  
    ```shell  
    python3 result_parser.py
    ```
    - 运行目录下存放logs logs_failed suite2cases catalog.json四个文件和文件夹，logs和logs_failed为测试结果，suite2cases为测试所用mugen的suite2cases文件夹，catalog.json为错因归类数据，在本仓库中有参考文件  
    - 运行此脚本生成result.json result.csv failureCause.csv三个文件，result.json为统计结果的原始数据，result.csv为各测试套通过/未通过的统计结果，failureCause.csv中为错因分析  