package com.benefits.common.error;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * Problem Details RFC 7807 compliant error response
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ProblemDetail {
    
    private String type;
    private String title;
    private Integer status;
    private String detail;
    private String instance;
    @Builder.Default
    private LocalDateTime timestamp = LocalDateTime.now();
    
    private String code;
    private Boolean retryable;
    private Map<String, Object> fields;
    private String correlationId;
    private String traceId;
}
