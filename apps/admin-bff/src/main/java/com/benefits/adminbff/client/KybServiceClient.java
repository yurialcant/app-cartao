package com.benefits.adminbff.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@FeignClient(name = "kyb-service", url = "${kybservice.service.url:http://kyb-service:8102}")
public interface KybServiceClient {
    
    @GetMapping("/api/kyb/{merchantId}")
    Map<String, Object> getKYB(@PathVariable String merchantId);
    
    @PutMapping("/api/kyb/{id}/verify")
    Map<String, Object> verifyKYB(
            @PathVariable String id,
            @RequestBody Map<String, Object> requestBody
    );
}
