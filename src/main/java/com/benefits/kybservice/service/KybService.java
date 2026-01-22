package com.benefits.kybservice.service;

import com.benefits.kybservice.provider.ReceitaWsKybProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class KybService {
    
    private final ReceitaWsKybProvider receitaWsProvider;
    
    public Map<String, Object> submitKYB(UUID merchantId, Map<String, Object> kybData) {
        log.info("🔵 [KYB-SERVICE] Submetendo KYB - merchantId: {}", merchantId);
        
        UUID kybId = UUID.randomUUID();
        String cnpj = (String) kybData.get("cnpj");
        
        Map<String, Object> response = new HashMap<>();
        response.put("kybId", kybId.toString());
        response.put("merchantId", merchantId.toString());
        response.put("status", "PENDING");
        response.put("submittedAt", java.time.LocalDateTime.now().toString());
        
        // Validar CNPJ usando ReceitaWS (baseado em API real)
        if (cnpj != null) {
            Map<String, Object> cnpjValidation = receitaWsProvider.consultarCnpj(cnpj);
            response.put("cnpjValidation", cnpjValidation);
            
            // Se CNPJ válido e ativo, aprovar automaticamente
            if ("ATIVA".equals(cnpjValidation.get("situacao"))) {
                response.put("status", "APPROVED");
                response.put("autoApproved", true);
            }
        }
        
        // TODO: Salvar no banco via Core Service
        
        return response;
    }
    
    public Map<String, Object> verifyKYB(UUID kybId, boolean approved, String reason) {
        log.info("🔵 [KYB-SERVICE] Verificando KYB - kybId: {}, approved: {}", kybId, approved);
        
        Map<String, Object> response = new HashMap<>();
        response.put("kybId", kybId.toString());
        response.put("status", approved ? "APPROVED" : "REJECTED");
        response.put("reason", reason != null ? reason : "");
        response.put("verifiedAt", java.time.LocalDateTime.now().toString());
        
        // TODO: Atualizar no banco e notificar merchant
        
        return response;
    }
    
    public Map<String, Object> consultarCnpj(String cnpj) {
        log.info("🔵 [KYB-SERVICE] Consultando CNPJ - CNPJ: {}", cnpj);
        
        // Usar ReceitaWS para consultar CNPJ
        return receitaWsProvider.consultarCnpj(cnpj);
    }
}
