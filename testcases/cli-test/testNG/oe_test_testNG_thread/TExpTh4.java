import org.testng.annotations.Test;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.AfterSuite;

public class TExpTh4 {
	private double beforetime;
	private double aftertime;

	@Test(invocationCount = 3800, threadPoolSize = 3800)
	public void testMethod() {
		System.out.println("Thread Id :" + Thread.currentThread().getId());
	}

	@BeforeSuite
	public void beforetest() {
		this.beforetime = System.currentTimeMillis();

	}

	@AfterSuite
	public void aftertest() {
		this.aftertime = System.currentTimeMillis();
		System.out.println("time is :" + (aftertime - beforetime));
	}
}