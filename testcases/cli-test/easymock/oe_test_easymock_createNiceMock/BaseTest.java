import junit.framework.TestCase;
import org.easymock.EasyMock;
import org.junit.Test;

public class BaseTest {
    @Test
    public void testBaseDao(){
        BaseDao baseDaoMock= EasyMock.createNiceMock(BaseDao.class);
        EasyMock.replay(baseDaoMock);
        BaseService baseService=new BaseService();
        baseService.setDao(baseDaoMock);
        String result=baseService.carryQuery("111");
        System.out.println("result="+result);
        EasyMock.verify(baseDaoMock);
    }
}
