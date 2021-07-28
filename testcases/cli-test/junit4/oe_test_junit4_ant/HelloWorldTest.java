import junit.framework.TestCase;
import junit.framework.TestSuite;
import org.junit.Test;

public class HelloWorldTest extends TestCase{
	public HelloWorldTest(String name){
		super(name);
	}

	public static void main(String args[]){
		junit.textui.TestRunner.run(HelloWorldTest.class);
	}

	@Test
	public void testSayHello(){
		HelloWorld world = new HelloWorld();
		assert (world != null);
		assertEquals("Hello World",world.sayHello());
	}	

	@Test
	public void testgetInt(){
		HelloWorld world = new HelloWorld();
		assertEquals(6,world.getInt());
	}
}
