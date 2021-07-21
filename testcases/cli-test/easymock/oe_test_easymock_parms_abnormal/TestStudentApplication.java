import org.easymock.EasyMock;  
import org.junit.Assert;  
import org.junit.Test;  
 
public class TestStudentApplication {  
    IStudent student;  
    StudentApplication application;  
    @Test  
    public void testdoMethod(){    
        student=EasyMock.createMock(IStudent.class);  
        EasyMock.expect(student.doMethod(EasyMock.geq(3))).andReturn(10);   
        EasyMock.replay(student);   
        application=new StudentApplication(student);  
        application.getStudent();  
        int getNum=application.doMethod(2);   
        int cnum=10;
        Assert.assertEquals(getNum, cnum);  
        EasyMock.verify(student);           
    }  
} 
