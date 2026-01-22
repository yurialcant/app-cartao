package com.benefits.adminbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@FeignClient(name = "kyc-service", url = "${kycservice.service.url:http://kyc-service:8101}")
public interface KycServiceClient {
    
    @GetMapping("/actuator/health")
    Map<String, Object> health();
    
    // TODO: Adicionar métodos específicos do serviço
}
