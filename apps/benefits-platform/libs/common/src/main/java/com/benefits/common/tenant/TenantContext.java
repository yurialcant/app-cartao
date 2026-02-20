package com.benefits.common.tenant;

import org.springframework.stereotype.Component;
import reactor.util.context.Context;

/**
 * Thread-local context for multi-tenant isolation
 * Stores tenant_id from JWT claim or header
 */
@Component
public class TenantContext {
    
    public static final String TENANT_ID_CONTEXT_KEY = "tenant_id";
    public static final String TENANT_ID_HEADER = "X-Tenant-Id";
    
    /**
     * Get current tenant ID from reactor context
     */
    public static String getCurrentTenant(Context context) {
        return context.getOrDefault(TENANT_ID_CONTEXT_KEY, "default");
    }
    
    /**
     * Get tenant ID as string (for manual extraction if needed)
     */
    public static String getTenantIdFromJwt(String jwtSubject) {
        // Subject format: "tenantId@userId"
        if (jwtSubject != null && jwtSubject.contains("@")) {
            return jwtSubject.split("@")[0];
        }
        return "default";
    }
    
    /**
     * Create context with tenant ID
     */
    public static Context withTenant(String tenantId) {
        return Context.of(TENANT_ID_CONTEXT_KEY, tenantId);
    }
}
