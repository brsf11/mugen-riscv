import org.junit.Test;
import junit.framework.AssertionFailedError;
import junit.framework.TestResult;
import static org.junit.Assert.*;

public class TestJunit3 extends TestResult {
	public synchronized void addError(Test test, Throwable t) {
		super.addError((junit.framework.Test) test, t);
		System.out.println(t);
	}

	public synchronized void addFailure(Test test, AssertionFailedError t) {
		super.addFailure((junit.framework.Test) test, t);
		System.out.println(t);
	}

	@Test
	public void testAdd() {
		TestResult result=new TestResult(); 
		System.out.println("Number of error = " + result.errorCount());
		System.out.println("Number of failure = " + result.failureCount());
		System.out.println("Number of test cases = " + result.runCount());
		String str="ok";
		assertEquals("not ok",str);
	}

	public synchronized void stop() {
		//stop the test here
	}
}
