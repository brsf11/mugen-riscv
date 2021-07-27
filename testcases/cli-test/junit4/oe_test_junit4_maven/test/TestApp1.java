package test.java.testJunitMaven;
import main.java.testJunitMaven.App;
import junit.framework.Assert;
import org.junit.Test;

public class TestApp1 {
	@Test
	public void testPrintHelloWorld() {
		App app=new App();
		Assert.assertEquals(app.getHelloWorld(), "Hello World");
	}
}
