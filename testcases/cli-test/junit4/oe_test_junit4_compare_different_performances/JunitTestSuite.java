import junit.framework.*;

public class JunitTestSuite {
	public static void main(String[] a) {
		long starTime=System.currentTimeMillis();      

		TestSuite suite = new TestSuite(TestJunit1.class, TestJunit3.class);
		suite.addTestSuite(TestJunit2.class);
		TestResult result = new TestResult();
		suite.run(result);

		long endTime=System.currentTimeMillis();
		long Time=endTime-starTime;
		System.out.println("JunitTestSuiteTime:"+Time);
		System.out.println("Number of testSuite cases = " + suite.testCount());
		System.out.println("Number of test cases = " + result.runCount());
		suite.setName("testNewName");
		String newName= suite.getName();
		System.out.println("Test Suite Name = "+ newName);
	}
}
