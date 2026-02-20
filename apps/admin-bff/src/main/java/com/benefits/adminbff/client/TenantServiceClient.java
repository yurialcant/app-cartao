package com.benefits.adminbff.client;

import com.benefits.adminbff.dto.TenantResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import java.util.List;

@FeignClient(name = "tenant-service", url = "${tenant.service.url:http://tenant-service:8106}")
public interface TenantServiceClient {

    @GetMapping("/api/tenants")
    List<TenantResponse> getAllTenants(@RequestHeader("X-Tenant-Id") String tenantId);

    @GetMapping("/api/tenants/{id}")
    TenantResponse getTenantById(@PathVariable String id, @RequestHeader("X-Tenant-Id") String tenantId);
}