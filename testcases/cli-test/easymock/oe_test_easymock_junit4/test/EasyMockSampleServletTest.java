package test.java.easymocktest;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import static junit.framework.Assert.assertFalse;
import static junit.framework.Assert.assertTrue;
import static org.easymock.EasyMock.*;
import main.java.easymocktest.SampleServlet;
 
public class EasyMockSampleServletTest {
    private SampleServlet sampleServlet;
    private HttpServletRequest mockHttpServletRequest;
    private HttpSession mockHttpSession;
    @Before
    public void setUp(){
        sampleServlet=new SampleServlet();
        mockHttpServletRequest=createStrictMock(HttpServletRequest.class);
        mockHttpSession = createStrictMock(HttpSession.class);
    }
    @Test
    public void testIsAuthenticatedAuthenticated() {
        expect(mockHttpServletRequest.getSession(eq(false))).andReturn(mockHttpSession);
        expect(mockHttpSession.getAttribute(eq("authenticated"))).andReturn("true");
        replay(mockHttpServletRequest);
        replay(mockHttpSession);
        assertTrue(sampleServlet.isAuthenticated(mockHttpServletRequest));
    }
    @Test
    public void testIsAuthenticatedNotAuthenticated() {
        expect(mockHttpSession.getAttribute(eq("authenticated"))).andReturn("false");
        replay(mockHttpSession);
        expect(mockHttpServletRequest.getSession(eq(false))).andReturn(mockHttpSession);
        replay(mockHttpServletRequest);
        assertFalse(sampleServlet.isAuthenticated(mockHttpServletRequest));
    }
    @Test
    public void testIsAuthenticatedNoSession() {
        expect(mockHttpServletRequest.getSession(eq(false))).andReturn(null);
        replay(mockHttpServletRequest);
        replay(mockHttpSession);
        assertFalse(sampleServlet.isAuthenticated(mockHttpServletRequest));
    }
    @After
    public void tearDown(){
        verify(mockHttpServletRequest);
        verify(mockHttpSession);
    }
}
