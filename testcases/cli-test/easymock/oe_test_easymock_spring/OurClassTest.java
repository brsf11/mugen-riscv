import static org.junit.Assert.assertTrue;
import org.easymock.EasyMock;
import org.junit.Test;
import org.springframework.test.util.ReflectionTestUtils;
import net.sf.cglib.proxy.Callback;

public class OurClassTest {
    @Test
    public void testOurClass() {
        OurClass classUnderTest = new OurClass();
        assertTrue("fun should return 0", classUnderTest.fun() == 0);      
        OtherClass other = new OtherClass() {
            public int fun() {
               return 1;
            }
        };

        ReflectionTestUtils.setField(classUnderTest, "other", other);
        assertTrue("fun should return 1", classUnderTest.fun() == 1);
        OtherClass other2 = EasyMock.mock(OtherClass.class);
        EasyMock.expect(other2.fun()).andReturn(2).times(1);
        EasyMock.replay(other2);
        ReflectionTestUtils.setField(classUnderTest, "other", other2);
        assertTrue("fun should return 2", classUnderTest.fun() == 2);
        EasyMock.verify(other2);
    }
}
