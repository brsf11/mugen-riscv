import os
import sys
import json
import argparse

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
        self.suite_cases_path = "./suite2cases"
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
        os.system("rm -rf ./logs/*")
        os.system("rm -rf ./results/*")
        os.system("rm -rf ./logs_failed/*")
        os.system("rm -f ./exec.log")
        if "logs_failed" not in os.listdir("."):
            os.system("mkdir logs_failed")
        self.is_cleared = 1

class TestTarget():
    """
    Test targets
    """

    def __init__(self,list_file_name):
        self.is_checked = 0
        self.is_tested = 0
        self.test_list = []
        self.unaval_test = []

        self.success_test_num = []
        self.failed_test_num = []

        list_file = open(list_file_name,'r')
        raw = list_file.read()
        self.test_list = raw.split(sep="\n")
        list_file.close()

    def PrintTargetNum(self):
        print("total test targets num = "+str(len(self.test_list)))

    def CheckTargets(self,suite_list_mugen,suite_list_riscv):
        self.unaval_test = []
        for test_target in self.test_list :
            if((test_target not in suite_list_riscv) and (test_target not in suite_list_mugen)):
                self.unaval_test.append(test_target)

        for test_target in self.unaval_test :
            self.test_list.remove(test_target)

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

    def Run(self,detailed = 0):
        if(self.is_checked != 1):
            LogError("Targets are not checked!")
            return 1
        else:
            for test_target in self.test_list :
                print("Start to test target: "+test_target)
                if detailed == False:
                    os.system("sudo bash mugen.sh -f "+test_target+" 2>&1 | tee -a exec.log")
                    temp_failed = []
                    try:
                        temp_failed = os.listdir("results/"+test_target+"/failed")
                    except:
                        failed_num = 0
                        self.failed_test_num.append(failed_num)
                    else:
                        failed_num = len(temp_failed)
                        self.failed_test_num.append(failed_num)
                        os.system("mkdir logs_failed/"+test_target)
                        for failed_test in temp_failed :
                            os.system("mkdir logs_failed/"+test_target+"/"+failed_test+"/")
                            os.system("cp logs/"+test_target+"/"+failed_test+"/*.log logs_failed/"+test_target+"/"+failed_test+"/")

                    temp_success = []
                    try:
                        temp_success = os.listdir("results/"+test_target+"/succeed")
                    except:
                        success_num = 0
                        self.success_test_num.append(success_num)
                    else:
                        success_num = len(temp_success)
                        self.success_test_num.append(success_num)
                else:
                    json_file = open("suite2cases/"+test_target+".json",'r')
                    json_raw = json_file.read()
                    json_data = json.loads(json_raw)
                    temp_failed = []
                    success_num = 0
                    failed_num = 0
                    for testcasedict in json_data['cases']:
                        testcase = testcasedict['name']
                        os.system("sudo bash mugen.sh -f "+test_target+" -r "+testcase+" 2>&1 | tee -a exec.log")
                        if(os.system("ls results/"+test_target+"/failed/"+testcase+" &> /dev/null") == 0):
                            failed_num += 1
                            temp_failed.append(testcase)
                            if(os.system("ls logs_failed/"+test_target+" &> /dev/null") != 0):
                                os.system("mkdir logs_failed/"+test_target)
                            os.system("mkdir logs_failed/"+test_target+"/"+testcase+"/")
                            os.system("cp logs/"+test_target+"/"+testcase+"/*.log logs_failed/"+test_target+"/"+testcase+"/")
                        if(os.system("ls results/"+test_target+"/succeed/"+testcase+" &> /dev/null") == 0):
                            success_num += 1

                        
                    
                print("Target "+test_target+" tested "+str(success_num+failed_num)+" cases, failed "+str(failed_num)+" cases")
                if(detailed == 1):
                    for failed_test in temp_failed :
                        print("Failed test: "+failed_test)

            self.is_tested = 1




if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-l',required=True,metavar='list_file',help='Specify the test targets list',dest='list_file')
    parser.add_argument('-m','--mugen',action='store_true',help='Run native mugen test suites')
    args = parser.parse_args()

    test_env = TestEnv()
    test_env.ClearEnv()
    test_env.PrintSuiteNum()

    test_target = TestTarget(list_file_name=args.list_file)
    test_target.PrintTargetNum()
    test_target.CheckTargets(suite_list_mugen=test_env.suite_list_mugen,suite_list_riscv=test_env.suite_list_riscv)
    test_target.PrintUnavalTargets()
    test_target.PrintAvalTargets()
    test_target.Run(detailed=True)
