import org.testng.annotations.Test;
import org.testng.annotations.Parameters;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Optional;
import org.testng.annotations.DataProvider;

public class TExpParameters {
	@BeforeMethod
	@Parameters("before")
	public void beforeParameter(String str) {
		System.out.println("Parameters can also be used for before/after and factory comments：" + str);
	}

	@Test
	@Parameters({ "name", "sex" })
	public void testParameters1(String name, String sex) {
		System.out.println("my name is:" + name);
		System.out.println("My gender is:" + sex);
	}

	@Test
	@Parameters("str")
	public void testParameters2(String str) {
		System.out.println(
				"In testng.xml, you can declare parameters under the <suite> tag or <test> tag. If the two parameters have the same name, the parameters defined under the <test> tag take precedence:"
						+ str);
	}

	@Test
	@Parameters("dbType")
	public void testParameters3(@Optional("mysql") String dbType) {
		System.out.println(
				"In testng.xml, the default value of the Optional annotation is used when there is no dbType parameter:"
						+ dbType);
	}

	@DataProvider(name = "datatest1")
	public Object[][] createData1() {
		return new Object[][] { { "yi", 2 }, { "er", 1 } };
	}

	@Test(dataProvider = "datatest1")
	public void providerTest1(String strname, int intname) {
		System.out.println("Digital reading:" + strname + ",The Arabic numerals are:" + intname);
	}
}