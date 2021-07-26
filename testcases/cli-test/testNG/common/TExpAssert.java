import org.testng.annotations.Test;
import org.testng.Assert;
import org.testng.asserts.SoftAssert;

public class TExpAssert {
	@Test
	public void assertTest1() {
		Assert.assertEquals(1, 1, "Two parameter values are not the same");
		System.out.println("Print the statement after the assertion11");
		Assert.assertEquals(1, 2, "Two parameter values not the same");
		System.out.println("Print the statement after the assertion12");
	}

	@Test
	public void assertTest2() {
		boolean a = false;
		boolean b = true;
		Assert.assertFalse(a, "Condition is not False");
		System.out.println("Print the statement after the assertion21");
		Assert.assertFalse(b, "Condition is not False");
		System.out.println("Print the statement after the assertion22");
	}

	@Test
	public void assertTest3() {
		SoftAssert assertion = new SoftAssert();
		assertion.assertEquals(1, 1, "Two parameter values are not equal");
		System.out.println("The statement after printing31");
		assertion.assertEquals(1, 2, "Two parameter values are not equal");
		System.out.println("The statement after printing32");
		assertion.assertAll();
	}

	@Test
	public void assertTest4() {
		Integer[] array1 = new Integer[] { 1, 2, 3 };
		Integer[] array2 = new Integer[] { 2, 3, 1 };
		Assert.assertEqualsNoOrder(array1, array2, "Two parameter values are not the same");
		System.out.println("Print the statement after the assertion41");
	}

	@Test
	public void assertTest5() {
		Assert.assertNotEquals(1, 2, "Both are the same");
		System.out.println("Print the statement after the assertion51");
	}

	@Test
	public void assertTest6() {
		int a = 1;
		Assert.assertNotNull(a, "Object is NULL");
		System.out.println("Print the statement after the assertion61");
	}

	@Test
	public void assertTest7() {
		String a = "a";
		String b = "a";
		Assert.assertSame(a, b, "Object id is different");
		System.out.println("Print the statement after the assertion71");
	}

	@Test
	public void assertTest8() {
		String a = "a";
		String b = "b";
		Assert.assertNotSame(a, b, "Same object id");
		System.out.println("Print the statement after the assertion81");
	}

	@Test
	public void assertTest9() {
		Boolean a = true;
		Assert.assertTrue(a, "Object value is FAlse");
		System.out.println("Print the statement after the assertion91");
	}
}