package main.java.junitest;

public class StudentApplication {  
    IStudent student=null;  
    public StudentApplication(IStudent student) {  
        this.student = student;  
    }  
      
    public int doMethod(int a){  
        int num1=student.doMethod1(a);  
        int num2=student.doMethod2(a);  
        int num3=student.doMethod3(a);  
        return num1+num2+num3;  
    }  
  
    public IStudent getStudent() {  
        return student;  
    }   
}
