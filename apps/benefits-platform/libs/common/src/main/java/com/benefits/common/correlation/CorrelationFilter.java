package com.benefits.common.correlation;

import org.slf4j.MDC;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebFilter;
import org.springframework.web.server.WebFilterChain;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * WebFilter to extract/generate X-Correlation-Id and X-Request-Id for request tracing
 */
@Component
public class CorrelationFilter implements WebFilter {
    
    public static final String CORRELATION_ID_HEADER = "X-Correlation-Id";
    public static final String REQUEST_ID_HEADER = "X-Request-Id";
    public static final String CORRELATION_ID_MDC_KEY = "correlation_id";
    public static final String REQUEST_ID_MDC_KEY = "request_id";
    
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, WebFilterChain chain) {
        String correlationId = exchange.getRequest().getHeaders()
            .getFirst(CORRELATION_ID_HEADER);
        if (correlationId == null || correlationId.isEmpty()) {
            correlationId = UUID.randomUUID().toString();
        }
        
        String requestId = exchange.getRequest().getHeaders()
            .getFirst(REQUEST_ID_HEADER);
        if (requestId == null || requestId.isEmpty()) {
            requestId = UUID.randomUUID().toString();
        }
        
        final String finalCorrelationId = correlationId;
        final String finalRequestId = requestId;
        
        // Add to response headers
        exchange.getResponse().getHeaders().add(CORRELATION_ID_HEADER, finalCorrelationId);
        exchange.getResponse().getHeaders().add(REQUEST_ID_HEADER, finalRequestId);
        
        return chain.filter(exchange)
            .doFinally(signal -> MDC.clear())
            .contextWrite(reactor.util.context.Context.of(
                CORRELATION_ID_MDC_KEY, finalCorrelationId,
                REQUEST_ID_MDC_KEY, finalRequestId
            ));
    }
}
