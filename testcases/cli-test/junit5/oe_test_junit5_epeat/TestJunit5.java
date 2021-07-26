package com.exmaple.junit5;
import org.junit.jupiter.api.*;

public class TestJunit5{
    @Nested
    @DisplayName("Nested1")
    class Nested1 {
        @BeforeEach
        void BeforeEach() {
            System.out.println("Nested1 beforeeach");
        }
        @Test
        @DisplayName("Nested1 TestA")
        void Nested1_TestA() {
            System.out.println("Nested1 TestA");
        }
        @Nested
        @DisplayName("Nested2 TestA")
        class AfterPushing {
            @BeforeEach
            void pushAnElement() {
                System.out.println("Nested2 beforeeach");
            }
            @Test
            @RepeatedTest(3)
            @DisplayName("Nested2 TestA")
            void Nested2_TestA() {
                System.out.println("Nested2 TestA");
            }

        }
    }
}
