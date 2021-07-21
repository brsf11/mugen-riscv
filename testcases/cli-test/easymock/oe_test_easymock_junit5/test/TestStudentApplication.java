package test.java.junitest;
import org.easymock.EasyMock;
import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;
import main.java.junitest.IStudent;
import main.java.junitest.StudentApplication;
  
public class TestStudentApplication {  
    IStudent student;  
    StudentApplication application;  
    @Test  
    public void testdoMethod(){   
        student=EasyMock.createMock(IStudent.class);   
        EasyMock.expect(student.doMethod1(EasyMock.lt(3))).andReturn(10);  
        EasyMock.expect(student.doMethod2(EasyMock.leq(2))).andReturn(20);  
        EasyMock.expect(student.doMethod3(EasyMock.gt(1))).andReturn(30);  
        EasyMock.replay(student);  
        application=new StudentApplication(student);  
        application.getStudent();  
        int getNum=application.doMethod(2);  
        int cnum=60;
        assertEquals(getNum, cnum);  
        EasyMock.verify(student);            
    }  
}
