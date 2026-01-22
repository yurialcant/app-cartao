package com.benefits.adminbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@FeignClient(name = "settlement-service", url = "${settlementservice.service.url:http://settlement-service:8096}")
public interface SettlementServiceClient {
    
    @GetMapping("/actuator/health")
    Map<String, Object> health();
    
    // TODO: Adicionar métodos específicos do serviço
}
