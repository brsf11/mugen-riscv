import org.testng.IHookCallBack;
import org.testng.IHookable;
import org.testng.ITestResult;

public class IHookableImp implements IHookable {
	@Override
	public void run(IHookCallBack iHookCallBack, ITestResult iTestResult) {
		System.out.println("Listening method IHookableImp has been executed");
		iHookCallBack.runTestMethod(iTestResult);
	}
}