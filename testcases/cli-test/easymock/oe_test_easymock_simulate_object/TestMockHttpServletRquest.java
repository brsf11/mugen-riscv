import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import junit.framework.TestCase;
import org.easymock.EasyMock;
import static org.easymock.EasyMock.createControl;
import org.easymock.IMocksControl;
import org.junit.Assert;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class TestMockHttpServletRquest {
    IMocksControl control = EasyMock.createControl();
	HttpServletRequest request = null;
	HttpSession session = null;
	@Before
	public void setUp() {
		request = control.createMock(HttpServletRequest.class); 
		session = control.createMock(HttpSession.class); 
	}
 
	@Test
	public void testWeb() {   
		EasyMock.expect(request.getParameter("name")).andReturn("landy");
		EasyMock.expect(request.getSession()).andStubReturn(session);		
		EasyMock.expect(session.getAttribute("name")).andReturn("landy");		
		control.replay(); 
		String name=request.getParameter("name");
		System.out.println(name);
		String landy=(String)session.getAttribute("name");
		System.out.println("landy:"+landy);
		Assert.assertEquals(landy, name);
	}
	
	@After
	public void tearDown() {		
		control.verify(); 
	}
 }
