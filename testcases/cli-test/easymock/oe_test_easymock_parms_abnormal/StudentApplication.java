public class StudentApplication {  
    IStudent student=null;  
    public StudentApplication(IStudent student) {  
        this.student = student;  
    }  
      
    public int doMethod(int a){  
        int num1=student.doMethod(a);   
        return num1;  
    }  
  
    public IStudent getStudent() {  
        return student;  
    }   
} 
