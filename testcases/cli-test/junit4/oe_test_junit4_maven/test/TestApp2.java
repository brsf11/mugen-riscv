package test.java.testJunitMaven;
import main.java.testJunitMaven.App;
import junit.framework.Assert;
import org.junit.Test;

public class TestApp2 {
	@Test
	public void testPrintHelloWorld2() {
		App app=new App();
		Assert.assertEquals(app.getHelloWorld2(), "Hello World 2");
	}
}
