package com.exmaple.junit5;
import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTimeout;

public class TestJunit5{
    @BeforeAll
    static void BeforeAll() {
        System.out.println("this BeforeAll");
    }
    @BeforeEach
    void BeforeEach() {
        System.out.println("this BeforeEach");
    }
    @AfterAll
    static void AfterAll() {
        System.out.println("this AfterAll");
    }
    @AfterEach
    void AfterEach() {
        System.out.println("this AfterEach");
    }
    @Test
    @Tag("showInfo")
    public void TestA(TestInfo info){
	System.out.println(info.getTags());
    }

    @Test
    @DisplayName("firsttest")
    void TestB() {
        assertEquals(2, 1+1);
    }    	
}
