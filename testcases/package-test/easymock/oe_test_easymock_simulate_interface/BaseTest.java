import junit.framework.TestCase;
import org.easymock.EasyMock;
import org.junit.Test;

public class BaseTest {
    @Test
    public void testBaseDao(){
        BaseDao baseDaoMock= EasyMock.createMock(BaseDao.class);
        EasyMock.expect(baseDaoMock.queryById(EasyMock.startsWith("1"))).andReturn("abin").times(2);
        baseDaoMock.queryById(EasyMock.contains("2"));
        EasyMock.expectLastCall().andReturn("tom").atLeastOnce();
        EasyMock.expect(baseDaoMock.queryById(EasyMock.endsWith("3"))).andReturn("candy").anyTimes();
        EasyMock.expect(baseDaoMock.queryById(EasyMock.matches("[1-9]*"))).andReturn("marry").anyTimes();
        EasyMock.replay(baseDaoMock);
        BaseService baseService=new BaseService();
        baseService.setDao(baseDaoMock);
        String result=baseService.carryQuery("111");
        System.out.println("result="+result);
        String result1=baseService.carryQuery("111");
        System.out.println("result1="+result1);
        String result2=baseService.carryQuery("222");
        System.out.println("result2="+result2);
        String result3=baseService.carryQuery("333");
        System.out.println("result3="+result3);
        String result4=baseService.carryQuery("333");
        System.out.println("result4="+result4);
        String result5=baseService.carryQuery("444");
        System.out.println("result5="+result5);
        TestCase.assertNotNull(result);
        TestCase.assertEquals("abin",result);
        EasyMock.verify(baseDaoMock);
    }
}
