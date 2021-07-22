package com.exmple.project;
import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

public class TestJunit5 {
 
    @ParameterizedTest
    @ValueSource(ints = {2, 4})
    void testA(int num) {
        assertEquals(0, num % 2);
        System.out.println(num);
    }
}
