import os
import sys
from tqdm import tqdm

def LogInfo(log_content=""):
    print("INFO:  "+log_content)

def LogError(log_content=""):
    print("ERROR: "+log_content)

class TestEnv():
    """
    Test environment
    """

    def __init__(self):
        self.is_cleared = 0
        self.suite_cases_path = "./suite2cases"
        self.suite_list = os.listdir(self.suite_cases_path)

        for i in range(len(self.suite_list)):
            self.suite_list[i] = self.suite_list[i].replace(".json","")

    def PrintSuiteNum(self):
        print("Available test suites num = "+str(len(self.suite_list)))

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

    def CheckTargets(self,test_env):
        self.unaval_test = []
        for test_target in self.test_list :
            if(test_target not in test_env.suite_list):
                self.unaval_test.append(test_target)

        for test_target in self.unaval_test :
            self.test_list.remove(test_target)

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
            for test_target in tqdm(self.test_list,file=sys.stdout,unit='case') :
                os.system("sudo bash mugen.sh -f "+test_target+" 2>> exec.log")
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

                tqdm.write("Target "+test_target+" tested "+str(success_num+failed_num)+" cases, failed "+str(failed_num)+" cases")
                if(detailed == 1):
                    for failed_test in temp_failed :
                        tqdm.write("Failed test: "+failed_test)

            self.is_tested = 1




if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Error: need to specify test list")
        print("Usage: python3 runtest.py test_list")
        sys.exit(-1)

    test_env = TestEnv()
    test_env.ClearEnv()
    test_env.PrintSuiteNum()

    test_target = TestTarget(list_file_name=sys.argv[1])
    test_target.PrintTargetNum()
    test_target.CheckTargets(test_env=test_env)
    test_target.PrintUnavalTargets()
    test_target.PrintAvalTargets()
    test_target.Run(detailed=1)
