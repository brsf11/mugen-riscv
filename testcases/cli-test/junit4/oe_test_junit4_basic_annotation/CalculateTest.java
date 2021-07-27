import static org.junit.Assert.*;
import org.junit.Test;
import org.junit.Ignore;

public class CalculateTest {
	Calculate mycal=new Calculate();
	
	@Test
	public void testAdd() {
		assertEquals(6,mycal.add(2, 4));
	}

	@Test(timeout=1000)
	public void testsubtract() {
		assertEquals(2,mycal.subtract(4,2));
		assertEquals(7,mycal.subtract(9, 2));
	}
	
	@Test
	@Ignore
	public void testmultiply() {
		assertEquals(15,mycal.multiply(3, 5));
		assertEquals(12,mycal.multiply(3, 4));
	}
}
