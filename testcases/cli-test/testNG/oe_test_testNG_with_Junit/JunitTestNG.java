import org.junit.Before;
import org.junit.Test;

public class JunitTestNG {
	@Before
	public void setUp() {
		System.out.println("begin test");
	}

	@Test
	public void testAdd() {
		System.out.println("its ok");
	}

}