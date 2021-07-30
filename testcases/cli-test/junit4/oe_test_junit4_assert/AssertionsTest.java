import org.junit.Test;
import static org.junit.Assert.*;
import java.util.ArrayList;
import java.util.List;

public class AssertionsTest {
	@Test
	public void testAssertNull() {
		String str = null;
		assertNull(str);
	}
 
	@Test
	public void testAssertNotNull() {
		String str = "hello Java!!";
		assertNotNull(str);
	}
 
	@Test
	public void testAssertTrue() {
		List<String> list = new ArrayList<String>();
		assertTrue(list.isEmpty());
	}
 
	@Test
	public void testAssertFalse() {
		List<String> list = new ArrayList<String>();
		list.add("hello");
		assertFalse(list.isEmpty());
	}
 
	@Test
	public void testAssertSame() {
		String str1 = "hello world!!";
		String str2 = "hello world!!";
		assertSame(str2, str1);
	}
 
	@Test
	public void testAssertNotSame() {
		String str1 = "hello world!!";
		String str3 = "hello Java!!";
		assertNotSame(str1, str3);
	}
	
	@Test
	public void testAssertArrayEquals() {
		String[] expectedArray = {"one", "two", "three"};
		String[] resultArray =  {"one", "two", "three"}; 
		assertArrayEquals(expectedArray, resultArray);
	}

	@Test
	public void testAssertEquals() {
		String str1 = new String ("abc");
		String str2 = new String ("abc");
		assertEquals(str1, str2);
	}
}
