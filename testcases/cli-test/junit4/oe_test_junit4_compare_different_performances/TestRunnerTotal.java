import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.runner.notification.Failure;

public class TestRunnerTotal{
	public static void main(String[] args){
		long starTime=System.currentTimeMillis();

		Result result=JUnitCore.runClasses(TestJunit1.class);
		for (Failure failure: result.getFailures()){
			System.out.println(failure.toString());
		}
		System.out.println(result.wasSuccessful());

		long endTime=System.currentTimeMillis();
		long Time1=endTime-starTime;
		System.out.println("TestJunit1Time:"+Time1);

		starTime=System.currentTimeMillis();
		result=JUnitCore.runClasses(TestJunit2.class);
		for (Failure failure: result.getFailures()){
			System.out.println(failure.toString());
		}
		System.out.println(result.wasSuccessful());

		endTime=System.currentTimeMillis();
		long Time2=endTime-starTime;
		System.out.println("TestJunit2Time:"+Time2);

  		starTime=System.currentTimeMillis();
		result=JUnitCore.runClasses(TestJunit3.class);
		for (Failure failure: result.getFailures()){
			System.out.println(failure.toString());
		}
		System.out.println(result.wasSuccessful());

		endTime=System.currentTimeMillis();
		long Time3=endTime-starTime;
		System.out.println("TestJunit3Time:"+Time3);
		long total=Time1+Time2+Time3;
		System.out.println("TestTotalTime:"+total);
	}
}
