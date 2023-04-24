from dataclasses import replace
import os
import sys
import json
import argparse
import re

def LogInfo(log_content=""):
    print("INFO:  "+log_content)

def LogError(log_content=""):
    print("ERROR: "+log_content)

class TestEnv():
    """
    Test environment
    Including testsuites in mugen
    """

    def __init__(self):
        self.is_cleared = 0
        self.suite_cases_path = "./suite2cases/"
        self.suite_list = os.listdir(self.suite_cases_path)
        self.suite_list_mugen = []
        self.suite_list_riscv = []

        for i in range(len(self.suite_list)):
            self.suite_list[i] = self.suite_list[i].replace(".json","")
            if (self.suite_list[i].find("-riscv") != -1):
                self.suite_list_riscv.append(self.suite_list[i].replace("-riscv",""))
            else:
                self.suite_list_mugen.append(self.suite_list[i])

        

    def PrintSuiteNum(self):
        print("Available mugen test suites num = "+str(len(self.suite_list_mugen)))
        print("Available riscv test suites num = "+str(len(self.suite_list_riscv)))

    def PrintMugenSuiteList(self):
        print("Available mugen test suites:")
        for testsuite in self.suite_list_mugen:
            print(testsuite)

    def PrintRiscvSuiteList(self):
        print("Available riscv test suites:")
        for testsuite in self.suite_list_riscv:
            print(testsuite)

    def ClearEnv(self):
        os.system("rm -rf ./results/*")
        os.system("rm -f ./exec.log")
        if "logs_failed" not in os.listdir("."):
            os.system("mkdir logs_failed")
        self.is_cleared = 1

    def AnalyzeMissingTests(self,ana_suite):
        if ana_suite is not None:
            if (ana_suite in self.suite_list_riscv) and (ana_suite in self.suite_list_mugen):
                mugen_file = open(self.suite_cases_path+ana_suite+".json",'r')
                riscv_file = open(self.suite_cases_path+ana_suite+"-riscv.json",'r')
                mugen_data = json.loads(mugen_file.read())
                riscv_data = json.loads(riscv_file.read())
                riscv_cases = []
                print("Test suite: "+ana_suite+"-riscv")
                for testcase in riscv_data['cases']:
                    riscv_cases.append(testcase['name'])
                for testcase in mugen_data['cases']:
                        if testcase['name'] not in riscv_cases:
                            print("Missing test case: "+testcase['name'])
        else:
            for riscv_suite in self.suite_list_riscv:
                if riscv_suite in self.suite_list_mugen:
                    mugen_file = open(self.suite_cases_path+riscv_suite+".json",'r')
                    riscv_file = open(self.suite_cases_path+riscv_suite+"-riscv.json",'r')
                    mugen_data = json.loads(mugen_file.read())
                    riscv_data = json.loads(riscv_file.read())
                    riscv_cases = []
                    start_tag = 0
                    for testcase in riscv_data['cases']:
                        riscv_cases.append(testcase['name'])
                    for testcase in mugen_data['cases']:
                        if testcase['name'] not in riscv_cases:
                            if start_tag == 0:
                                start_tag = 1
                                print("Test suite: "+riscv_suite+"-riscv")
                            print("Missing test case: "+testcase['name'])


class TestTarget():
    """
    Test targets
    """

    def __init__(self,list_file_name=None):
        self.is_checked = 0
        self.is_tested = 0
        self.test_list = []
        self.unaval_test = []

        self.success_test_num = []
        self.failed_test_num = []

        if list_file_name is not None:
            list_file = open(list_file_name,'r')
            raw = list_file.read()
            self.test_list = raw.split(sep="\n")
            list_file.close()

            self.test_list = [x.strip() for x in self.test_list if x.strip()!='']  #Remove empty elements
            self.test_list = [x.replace("-riscv","") for x in self.test_list]      #Remove -riscv suffix
        else:
            self.test_list = []

    def PrintTargetNum(self):
        print("total test targets num = "+str(len(self.test_list)))

    def CheckTargets(self,suite_list_mugen,suite_list_riscv,mugen_native = False,qemu_mode=False):
        if not qemu_mode:
            conf_path = "./conf/env.json"
            if not os.path.exists(conf_path):
                print("环境配置文件不存在，请先配置环境信息.")
                sys.exit(1)

        self.unaval_test = []
        for test_target in self.test_list :
            if(((test_target not in suite_list_riscv) or mugen_native) and (test_target not in suite_list_mugen)):
                self.unaval_test.append(test_target)

        for test_target in self.unaval_test :
            self.test_list.remove(test_target)

        if not mugen_native:
            for i in range(len(self.test_list)):
                if(self.test_list[i] in suite_list_riscv):
                    self.test_list[i] = self.test_list[i] + "-riscv"

        self.is_checked = 1

    def printTargets(self):
        print("All targets:")
        for test_target in self.test_list :
            print(test_target)

    def PrintUnavalTargets(self):
        print("Unavailable test targets:")
        for test_target in self.unaval_test :
            print(test_target)

    def PrintAvalTargets(self):
        if(self.is_checked != 1):
            LogError("Targets are not checked!")
            return 1
        else:
            print("Available test targets:")
            for test_target in self.test_list :
                print(test_target)

    def Run(self,xpara = False,addDisk = False,multiMachine = False,addNic = False):
        if(self.is_checked != 1):
            LogError("Targets are not checked!")
            return 1
        else:
            test_res = []
            for test_target in self.test_list :
                print("Start to test target: "+test_target)
                json_file = open("suite2cases/"+test_target+".json",'r')
                json_raw = json_file.read()
                json_data = json.loads(json_raw)
                temp_failed = []
                temp_succeed = []
                success_num = 0
                failed_num = 0
                for testcasedict in json_data['cases']:
                    if not addDisk and testcasedict.__contains__('add disk'):
                        continue
                    if not multiMachine and testcasedict.__contains__('machine num'):
                        continue
                    if not addNic and testcasedict.__contains__('add network interface'):
                        continue
                    
                    testcase = testcasedict['name']
                    if xpara:
                        os.system("sudo bash mugen.sh -f "+test_target+" -r "+testcase+" -x 2>&1 | tee -a exec.log")
                    else:
                        os.system("sudo bash mugen.sh -f "+test_target+" -r "+testcase+" 2>&1 | tee -a exec.log")
                    for log in  os.listdir('logs/'+test_target+'/'+testcase):
                        with open('logs/'+test_target+'/'+testcase+'/'+log , "r") as log_data:
                            log_found = re.search(r'See "systemctl status (.*)" and "journalctl -xe(.*)" for details.' , log_data.read())
                            if log_found is not None:
                                os.system("sudo journalctl -xe --no-pager > logs/"+test_target+'/'+testcase+"/journelctl_for_"+log)
                                os.system("sudo systemctl status "+log_found.group(1)+" --no-pager > logs/"+test_target+'/'+testcase+"/systemctl_for_"+log)

                    if(os.system("ls results/"+test_target+"/failed/"+testcase+" &> /dev/null") == 0):
                        failed_num += 1
                        temp_failed.append(testcase)
                        if test_target not in os.listdir('logs_failed/'):
                            os.system("mkdir logs_failed/"+test_target)
                        if testcase not in os.listdir("logs_failed/"+test_target+"/"):
                            os.system("mkdir logs_failed/"+test_target+"/"+testcase+"/")
                        logs = os.listdir('logs/'+test_target+"/"+testcase+"/")
                        os.system("cp logs/"+test_target+"/"+testcase+"/"+logs[len(logs)-1]+" logs_failed/"+test_target+"/"+testcase+"/")
                    if(os.system("ls results/"+test_target+"/succeed/"+testcase+" &> /dev/null") == 0):
                        temp_succeed.append(testcase)
                        success_num += 1
                target_res = {'suite': test_target,'failed': temp_failed,'succeed': temp_succeed}

                test_res.append(target_res)
                    
                print("Target "+test_target+" tested "+str(success_num+failed_num)+" cases, failed "+str(failed_num)+" cases")
                for failed_test in temp_failed :
                    print("Failed test: "+failed_test)
                

            self.is_tested = 1
            return test_res

class SuiteGenerator(TestEnv):
    def __init__(self):
        super().__init__()
        self.output_path = 'suite2cases_out/'
        if self.output_path.replace('/','') not in os.listdir("."):
            os.system("mkdir "+self.output_path)

    def GenJson(self,test_res):
        print("Json file generated at "+self.output_path)
        for target in test_res:
            suite_file = open(self.suite_cases_path+target['suite']+'.json','r')
            suite_json = json.loads(suite_file.read())
            mugen_cases = suite_json['cases']
            out_cases = [cases for cases in mugen_cases if cases['name'] in target['succeed']]
            suite_json['cases'] = out_cases
            out_file = open(self.output_path+target['suite']+'.json','w')
            out_file.write(json.dumps(suite_json,indent=4))
            print(self.output_path+target['suite']+'.json')
        
            



if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-l',metavar='list_file',help='Specify the test targets list',dest='list_file')
    parser.add_argument('-m','--mugen',action='store_true',help='Run native mugen test suites')
    parser.add_argument('-a','--analyze',action='store_true',help='Analyze missing testcases')
    parser.add_argument('-g','--generate',action='store_true',help='Generate testsuite json after running test')
    parser.add_argument('-f',metavar='test_suite',help='Specify testsuite',dest='test_suite',default=None)
    parser.add_argument('-x',action='store_true',help='-x parameter')
    parser.add_argument('--addDisk',action='store_true')
    parser.add_argument('--multiMachine',action='store_true')
    parser.add_argument('--addNic',action='store_true')
    args = parser.parse_args()

    test_env = TestEnv()
    test_env.ClearEnv()
    test_env.PrintSuiteNum()

    if args.analyze is True:
        if args.test_suite is not None:
            test_env.AnalyzeMissingTests(args.test_suite)
        else:
            test_env.AnalyzeMissingTests(None)
    else:
        if args.list_file is not None:
            test_target = TestTarget(list_file_name=args.list_file)
            test_target.PrintTargetNum()
            test_target.CheckTargets(suite_list_mugen=test_env.suite_list_mugen,suite_list_riscv=test_env.suite_list_riscv,mugen_native=args.mugen)
            test_target.PrintUnavalTargets()
            test_target.PrintAvalTargets()
            test_res = test_target.Run(xpara=args.x,addDisk=args.addDisk,multiMachine=args.multiMachine,addNic=args.addNic)
            if args.generate == True:
                gen = SuiteGenerator()
                gen.GenJson(test_res)
        elif args.test_suite is not None:
            test_target = TestTarget()
            test_target.test_list.append(args.test_suite)
            test_target.PrintTargetNum()
            test_target.CheckTargets(suite_list_mugen=test_env.suite_list_mugen,suite_list_riscv=test_env.suite_list_riscv,mugen_native=args.mugen)
            test_target.PrintUnavalTargets()
            test_target.PrintAvalTargets()
            test_res = test_target.Run(xpara=args.x,addDisk=args.addDisk,multiMachine=args.multiMachine,addNic=args.addNic)
            if args.generate == True:
                gen = SuiteGenerator()
                gen.GenJson(test_res)

