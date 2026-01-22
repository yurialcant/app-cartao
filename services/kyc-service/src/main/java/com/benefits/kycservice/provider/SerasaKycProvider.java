package com.benefits.kycservice.provider;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 * Stub baseado na API real do Serasa
 * Documentação: https://developers.serasa.com.br/
 * 
 * Este stub imita a estrutura de resposta da API real do Serasa para consulta de CPF e score.
 */
@Slf4j
@Component
public class SerasaKycProvider {
    
    private final Random random = new Random();
    
    @Value("${serasa.api-key:test-key}")
    private String apiKey;
    
    /**
     * Consultar CPF baseado na API real do Serasa
     * Endpoint real: POST /consulta-cpf
     */
    public Map<String, Object> consultarCpf(String cpf) {
        log.info("🔵 [SERASA-STUB] Consultando CPF - CPF: {}", cpf);
        
        Map<String, Object> response = new HashMap<>();
        response.put("cpf", cpf);
        response.put("nome", "Nome do Portador");
        response.put("data_nascimento", "1990-01-01");
        response.put("situacao_cpf", "REGULAR");
        response.put("data_consulta", LocalDateTime.now().toString());
        
        return response;
    }
    
    /**
     * Consultar score baseado na API real do Serasa
     * Endpoint real: POST /score
     */
    public Map<String, Object> consultarScore(String cpf) {
        log.info("🔵 [SERASA-STUB] Consultando score - CPF: {}", cpf);
        
        // Score de 0 a 1000 (padrão Serasa)
        int score = 300 + random.nextInt(700); // Score entre 300 e 1000
        
        Map<String, Object> response = new HashMap<>();
        response.put("cpf", cpf);
        response.put("score", score);
        response.put("faixa_score", getFaixaScore(score));
        response.put("data_consulta", LocalDateTime.now().toString());
        
        return response;
    }
    
    /**
     * Faixa de score baseada no padrão Serasa
     */
    private String getFaixaScore(int score) {
        if (score >= 900) return "MUITO_ALTO";
        if (score >= 700) return "ALTO";
        if (score >= 500) return "MEDIO";
        if (score >= 300) return "BAIXO";
        return "MUITO_BAIXO";
    }
}
