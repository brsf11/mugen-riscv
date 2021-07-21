import junit.framework.TestCase;
import org.easymock.EasyMock;
import org.junit.Test;

public class BaseTest {
    @Test
    public void testBaseDao(){
        BaseDao baseDaoMock= EasyMock.createMock(BaseDao.class);
        RuntimeException runtimeException=new RuntimeException("The id is not exist");
        EasyMock.expect(baseDaoMock.queryById(EasyMock.anyObject())).andThrow(runtimeException);
	EasyMock.replay(baseDaoMock);
        BaseService baseService=new BaseService();
        baseService.setDao(baseDaoMock);
        String result=baseService.carryQuery("111");
    }
}
