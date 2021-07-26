package com.exmaple.junit5;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.assertTimeout;

public class TestJunit5 {

   @Test   
   @Timeout(1000)
    public void testCalculate1() {
        Long l1 = 0L;
        Long l2 = 1L;
    	Long l = 0L;  
   		for (int i = 0; i < 100000; i++) {  
        	l = l1 + l2;
       		l1 = l2;
       		l2 = l;
   		 }  
    System.out.println(l);
    }

	private static long getFibo(long i) {  
        if (i == 1 || i == 2){
            return 1L;  
        }else{
            return getFibo(i - 1) + getFibo(i - 2); 
		} 
	}
}
