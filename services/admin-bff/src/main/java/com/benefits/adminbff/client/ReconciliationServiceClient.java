package com.benefits.adminbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@FeignClient(name = "recon-service", url = "${reconservice.service.url:http://recon-service:8097}")
public interface ReconciliationServiceClient {
    
    @GetMapping("/actuator/health")
    Map<String, Object> health();
    
    // TODO: Adicionar métodos específicos do serviço
}
