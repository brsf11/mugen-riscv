package com.example.project;
import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;

class SecondTest {

    @Test
    @Tag("slow")
    void aSlowTest() throws InterruptedException {
        Thread.sleep(1000);
    }
}
