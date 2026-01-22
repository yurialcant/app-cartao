package com.benefits.adminbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@FeignClient(name = "audit-service", url = "${auditservice.service.url:http://audit-service:8099}")
public interface AuditServiceClient {
    
    @GetMapping("/actuator/health")
    Map<String, Object> health();
    
    // TODO: Adicionar métodos específicos do serviço
}
