public class BaseService {
    private BaseDao baseDao;
    public void setDao(BaseDao baseDao){
        this.baseDao=baseDao;
    }

    public String carryQuery(String id){
        return this.baseDao.queryById(id);
    }
}
