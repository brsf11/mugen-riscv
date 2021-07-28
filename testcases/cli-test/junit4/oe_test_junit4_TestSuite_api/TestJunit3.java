import org.junit.Test;
import junit.framework.AssertionFailedError;
import junit.framework.TestResult;

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
		//add any test
	}

	public synchronized void stop() {
		//stop the test here
	}
}

