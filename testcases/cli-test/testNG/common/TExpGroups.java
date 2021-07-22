import org.testng.annotations.Test;

@Test(groups = { "classgroup" })
public class TExpGroups {
	@Test(groups = { "methodgroup1", "methodgroup2" })
	public void testGroups1() {
		System.out.println("Method testGroups1 has been run");
	}

	@Test(groups = { "linux" })
	public void testGroups2() {
		System.out.println("Method testGroups2 has been run");
	}

	@Test(groups = { "windows" })
	public void testGroups3() {
		System.out.println("Method testGroups3 has been run");
	}

	@Test(groups = { "methodgroup1", "linux" })
	public void testGroups4() {
		System.out.println("Method testGroups4 has been run");
	}

	@Test(groups = { "linux.methodgroup1" })
	public void testGroups5() {
		System.out.println("Method testGroups5 has been run");
	}

	@Test(groups = { "linux.methodgroup2" })
	public void testGroups6() {
		System.out.println("Method testGroups6 has been run");
	}

	@Test(groups = { "methodgroup1" })
	public void testGroups7() {
		System.out.println("Method testGroups7 has been run");
	}

	@Test(groups = { "methodgroup1" })
	private void testGroups8() {
		System.out.println("Method testGroups8 has been run");
	}
}