package com.benefits.kycservice.service;

import com.benefits.kycservice.provider.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class KycService {
    
    private final SerproKycProvider serproProvider;
    private final SerasaKycProvider serasaProvider;
    private final FaceTecBiometricProvider faceTecProvider;
    
    @Value("${kyc.cpf.provider:serpro}")
    private String cpfProvider;
    
    @Value("${kyc.biometric.provider:facetec}")
    private String biometricProvider;
    
    public Map<String, Object> submitKYC(String userId, Map<String, Object> kycData) {
        log.info("🔵 [KYC-SERVICE] Submetendo KYC - userId: {}", userId);
        
        UUID kycId = UUID.randomUUID();
        String cpf = (String) kycData.get("cpf");
        String rg = (String) kycData.get("rg");
        String cnh = (String) kycData.get("cnh");
        String selfieBase64 = (String) kycData.get("selfie");
        
        Map<String, Object> response = new HashMap<>();
        response.put("kycId", kycId.toString());
        response.put("userId", userId);
        response.put("status", "PENDING");
        response.put("submittedAt", java.time.LocalDateTime.now().toString());
        
        // Validar CPF usando provider real
        Map<String, Object> cpfValidation;
        if ("serpro".equals(cpfProvider)) {
            cpfValidation = serproProvider.consultarCpf(cpf);
        } else {
            cpfValidation = serasaProvider.consultarCpf(cpf);
        }
        response.put("cpfValidation", cpfValidation);
        
        // Validar documentos
        if (rg != null || cnh != null) {
            Map<String, Object> docValidation = serproProvider.validarDocumentos(cpf, rg, cnh);
            response.put("documentValidation", docValidation);
        }
        
        // Validar biometria facial
        if (selfieBase64 != null && "facetec".equals(biometricProvider)) {
            Map<String, Object> biometricValidation = faceTecProvider.capturarSelfie3D(selfieBase64);
            response.put("biometricValidation", biometricValidation);
        }
        
        // TODO: Salvar no banco via Core Service
        
        return response;
    }
    
    public Map<String, Object> verifyKYC(UUID kycId, boolean approved, String reason) {
        log.info("🔵 [KYC-SERVICE] Verificando KYC - kycId: {}, approved: {}", kycId, approved);
        
        Map<String, Object> response = new HashMap<>();
        response.put("kycId", kycId.toString());
        response.put("status", approved ? "APPROVED" : "REJECTED");
        response.put("reason", reason != null ? reason : "");
        response.put("verifiedAt", java.time.LocalDateTime.now().toString());
        
        // TODO: Atualizar no banco e notificar usuário
        
        return response;
    }
    
    public Map<String, Object> consultarScore(String cpf) {
        log.info("🔵 [KYC-SERVICE] Consultando score - CPF: {}", cpf);
        
        // Usar Serasa para score
        return serasaProvider.consultarScore(cpf);
    }
}
