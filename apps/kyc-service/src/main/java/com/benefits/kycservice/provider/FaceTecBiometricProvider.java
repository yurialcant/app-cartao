package com.benefits.kycservice.provider;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.UUID;

/**
 * Stub baseado na API real do FaceTec (Biometria Facial)
 * Documentação: https://dev.facetec.com/
 * 
 * Este stub imita a estrutura de resposta da API real do FaceTec para verificação biométrica.
 */
@Slf4j
@Component
public class FaceTecBiometricProvider {
    
    private final Random random = new Random();
    
    @Value("${facetec.api-key:test-key}")
    private String apiKey;
    
    /**
     * Capturar selfie 3D baseado na API real do FaceTec
     * Endpoint real: POST /3d-face-scan
     */
    public Map<String, Object> capturarSelfie3D(String base64Image) {
        log.info("🔵 [FACETEC-STUB] Capturando selfie 3D");
        
        String sessionId = UUID.randomUUID().toString();
        boolean livenessDetected = random.nextInt(100) < 95; // 95% de liveness detectado
        
        Map<String, Object> response = new HashMap<>();
        response.put("session_id", sessionId);
        response.put("liveness_detected", livenessDetected);
        response.put("face_match_score", livenessDetected ? 0.85 + random.nextDouble() * 0.15 : 0.0);
        response.put("status", livenessDetected ? "SUCCESS" : "FAILED");
        response.put("timestamp", LocalDateTime.now().toString());
        
        if (livenessDetected) {
            response.put("face_template", UUID.randomUUID().toString());
        }
        
        return response;
    }
    
    /**
     * Verificar liveness baseado na API real do FaceTec
     * Endpoint real: POST /liveness-check
     */
    public Map<String, Object> verificarLiveness(String sessionId, String base64Image) {
        log.info("🔵 [FACETEC-STUB] Verificando liveness - SessionId: {}", sessionId);
        
        boolean livenessPassed = random.nextInt(100) < 90; // 90% passa
        
        Map<String, Object> response = new HashMap<>();
        response.put("session_id", sessionId);
        response.put("liveness_passed", livenessPassed);
        response.put("liveness_score", livenessPassed ? 0.80 + random.nextDouble() * 0.20 : 0.0);
        response.put("status", livenessPassed ? "PASSED" : "FAILED");
        response.put("timestamp", LocalDateTime.now().toString());
        
        return response;
    }
    
    /**
     * Comparar faces baseado na API real do FaceTec
     */
    public Map<String, Object> compararFaces(String faceTemplate1, String faceTemplate2) {
        log.info("🔵 [FACETEC-STUB] Comparando faces");
        
        double matchScore = 0.70 + random.nextDouble() * 0.30; // Score entre 0.70 e 1.0
        boolean match = matchScore >= 0.80;
        
        Map<String, Object> response = new HashMap<>();
        response.put("match", match);
        response.put("match_score", matchScore);
        response.put("confidence", matchScore);
        response.put("timestamp", LocalDateTime.now().toString());
        
        return response;
    }
}
