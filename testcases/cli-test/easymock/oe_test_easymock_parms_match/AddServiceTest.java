import static org.junit.Assert.*;
import org.easymock.EasyMock;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class AddServiceTest {
    int[] data1={1,2};
    int[] data2={1,2};
    int[] data3=data1;
    private AddInter addInter;
    @Before
    public void setUp() throws ClassNotFoundException {
        addInter=EasyMock.createMock(AddInter.class);
    }
    @Test
    public void testAdd() {
        EasyMock.expect(addInter.add(EasyMock.aryEq(data1))).andReturn(3);
        EasyMock.expect(addInter.add(EasyMock.same(data1))).andReturn(3);
        EasyMock.replay(addInter);
        assertEquals(3,addInter.add(data2));
        assertEquals(3,addInter.add(data3));
        EasyMock.verify(addInter);
    }
}
