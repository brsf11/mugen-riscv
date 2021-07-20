import junit.framework.TestCase;
import org.easymock.EasyMock;
import org.junit.Test;

public class BaseTest {
    @Test
    public void testBaseDao(){
        BaseDao baseDaoMock= EasyMock.createStrictMock(BaseDao.class);
        EasyMock.expect(baseDaoMock.queryById("111")).andReturn("abin");
        EasyMock.expect(baseDaoMock.queryById("222")).andReturn("tom");
        EasyMock.replay(baseDaoMock);
        BaseService baseService=new BaseService();
        baseService.setDao(baseDaoMock);
        String result1=baseService.carryQuery("222");
        System.out.println("result1="+result1);
        String result=baseService.carryQuery("111");
        System.out.println("result="+result);
        EasyMock.verify(baseDaoMock);
    }
}
