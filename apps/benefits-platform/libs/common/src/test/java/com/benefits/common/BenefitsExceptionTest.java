package com.benefits.common;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class BenefitsExceptionTest {

    @Test
    void benefitsException_ShouldWorkCorrectly() {
        BenefitsException ex = new BenefitsException("Test error");
        assertEquals("Test error", ex.getMessage());
        assertNotNull(ex);
    }

    @Test
    void problemDetail_ShouldWorkCorrectly() {
        ProblemDetail detail = new ProblemDetail();
        assertNotNull(detail, "ProblemDetail should be created");
    }
}
