import org.testng.annotations.Test;

public class Retry {
	@Test()
	public void testMethod() {
		System.out.println(1 / 0);
	}
}