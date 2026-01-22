package com.benefits.merchantbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@FeignClient(name = "acquirer-adapter", url = "${acquireradapter.service.url:http://acquirer-adapter:8093}")
public interface AcquirerServiceClient {
    
    @GetMapping("/actuator/health")
    Map<String, Object> health();
    
    // TODO: Adicionar métodos específicos do serviço
}

