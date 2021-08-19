import junit.framework.TestCase;
import org.junit.Before;
import org.junit.Test;
import org.junit.After;

public class TestJunit2 extends TestCase  {
	protected double fValue1;
	protected double fValue2;

	@Before 
	public void setUp() {
		fValue1= 2.0;
		fValue2= 3.0;
	}

	@Test
	public void testAdd() {
		System.out.println("No of Test Case = "+ this.countTestCases());
		String name= this.getName();
		System.out.println("Test Case Name = "+ name);
		this.setName("testNewAdd");
		String newName= this.getName();
		System.out.println("Updated Test Case Name = "+ newName);
	}

	@After
	public void tearDown() {
		//tearDown used to close the connection or clean up activities
	}
}
