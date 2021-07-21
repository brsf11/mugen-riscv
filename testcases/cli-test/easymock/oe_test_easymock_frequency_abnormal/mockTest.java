import static org.junit.Assert.assertEquals;
import org.easymock.EasyMock;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class mockTest {
	@Before
	public void printBefore(){
		System.out.println("my easymock test");
	}
	
	@Test
	public void test1() {
		System.out.println("Start test");
		mock my = EasyMock.createMock(mock.class);
		EasyMock.expect(my.pay(30)).andReturn(300).times(2);
		EasyMock.replay(my);
		assertEquals(300, my.pay(30));
		EasyMock.verify(my);
	}

	@After
	public void printAfter(){
		System.out.println("test end");
        }
}
