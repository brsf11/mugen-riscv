import org.testng.annotations.Test;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.AfterTest;
import org.testng.annotations.AfterSuite;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.AfterClass;

public class TExpBase {
	@BeforeClass
	public void beforeClass() {
		System.out.println("@BeforeClass");
	}

	@BeforeSuite
	public void beforeSuite() {
		System.out.println("@BeforeSuite");
	}

	@BeforeTest
	public void beforeTest() {
		System.out.println("@BeforeTest");
	}

	@BeforeMethod
	public void beforeMethod() {
		System.out.println("@BeforeMethod");
	}

	@AfterMethod
	public void afterMethod() {
		System.out.println("@AfterMethod");
	}

	@AfterTest
	public void afterTest() {
		System.out.println("@AfterTest");
	}

	@AfterSuite
	public void afterSuite() {
		System.out.println("@AfterSuite");
	}

	@AfterClass
	public void afterClass() {
		System.out.println("@AfterClass");
	}

	@Test
	public void testBase1() {
		System.out.println("testBase1");
	}

	@Test
	public void testBase2() {
		System.out.println("testBase2");
	}
}
