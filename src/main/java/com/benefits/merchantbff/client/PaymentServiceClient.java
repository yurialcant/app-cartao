package com.benefits.merchantbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@FeignClient(name = "payments-orchestrator", url = "${paymentsorchestrator.service.url:http://payments-orchestrator:8092}")
public interface PaymentServiceClient {
    
    @GetMapping("/actuator/health")
    Map<String, Object> health();
    
    // TODO: Adicionar métodos específicos do serviço
}

