package com.exmple.junit5;
import static org.junit.jupiter.api.Assertions.assertEquals;
 
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
 
import java.util.EnumSet;
import java.util.concurrent.TimeUnit;
import org.junit.jupiter.params.provider.EnumSource;
import org.junit.jupiter.params.provider.EnumSource.Mode;
import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertNotNull;
 
import java.util.stream.IntStream;
import java.util.stream.Stream;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;
 
import java.util.HashMap;
import java.util.Map;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

public class TestJunit5 {
 
    @ParameterizedTest
    @ValueSource(ints = {2, 4})
    void testA(int num) {
        assertEquals(0, num % 2);
        System.out.println(num);
    }
 
    @ParameterizedTest
    @ValueSource(strings = {"Radar", "Rotor"})
    void testB(String word) {
        assertEquals(isPalindrome(word), true);
        System.out.println(word);
    }
 
    @ParameterizedTest
    @ValueSource(doubles = {2.D})
    void testC(double num) {
        assertEquals(0, num % 2);
        System.out.println(num);
    }
 
    boolean isPalindrome(String word) {
        return word.toLowerCase().equals(new StringBuffer(word.toLowerCase()).reverse().toString());
    }
 
    @ParameterizedTest
    @EnumSource(value = TimeUnit.class, names = {"SECONDS", "MINUTES"})
    void testD(TimeUnit unit) {
        assertTrue(EnumSet.of(TimeUnit.SECONDS, TimeUnit.MINUTES).contains(unit));
        assertFalse(EnumSet
        .of(TimeUnit.DAYS, TimeUnit.HOURS, TimeUnit.MILLISECONDS, TimeUnit.NANOSECONDS,
            TimeUnit.MICROSECONDS).contains(unit));
    }
 
@ParameterizedTest
    @MethodSource("stringGenerator")
    void testE(String arg){
        assertNotNull(arg);
    }
 
    static Stream<String> stringGenerator(){
        return Stream.of("hello", "world", "let's", "test");
    }
 
    Map<Long, String> idToUsername = new HashMap<>();

    {
        idToUsername.put(1L, "Selma");
        idToUsername.put(2L, "Lisa");
        idToUsername.put(3L, "Tim");
    }

    @ParameterizedTest
    @CsvSource({"1,Selma", "2,Lisa", "3,Tim"})
    void testF(long id, String name) {
        assertTrue(idToUsername.containsKey(id));
        assertTrue(idToUsername.get(id).equals(name));
    }
}
