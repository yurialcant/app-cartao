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
 * Stub baseado na API real do Serpro
 * Documentação: https://developers.serpro.gov.br/
 * 
 * Este stub imita a estrutura de resposta da API real do Serpro para consulta de CPF.
 */
@Slf4j
@Component
public class SerproKycProvider {
    
    private final Random random = new Random();
    
    @Value("${serpro.api-key:test-key}")
    private String apiKey;
    
    /**
     * Consultar CPF baseado na API real do Serpro
     * Endpoint real: GET /consulta-cpf/{cpf}
     */
    public Map<String, Object> consultarCpf(String cpf) {
        log.info("🔵 [SERPRO-STUB] Consultando CPF - CPF: {}", cpf);
        
        // Simular validação de CPF
        boolean isValid = validarCpf(cpf);
        
        Map<String, Object> response = new HashMap<>();
        response.put("cpf", cpf);
        response.put("situacao", isValid ? "REGULAR" : "IRREGULAR");
        response.put("nome", isValid ? "Nome do Portador" : null);
        response.put("data_nascimento", isValid ? "1990-01-01" : null);
        response.put("sexo", isValid ? "M" : null);
        response.put("data_consulta", LocalDateTime.now().toString());
        response.put("codigo_retorno", isValid ? "0" : "1");
        response.put("mensagem_retorno", isValid ? "CPF válido" : "CPF inválido");
        
        return response;
    }
    
    /**
     * Validar documentos baseado na API real do Serpro
     * Endpoint real: POST /validacao-documentos
     */
    public Map<String, Object> validarDocumentos(String cpf, String rg, String cnh) {
        log.info("🔵 [SERPRO-STUB] Validando documentos - CPF: {}", cpf);
        
        boolean cpfValido = validarCpf(cpf);
        boolean rgValido = rg != null && rg.length() >= 7;
        boolean cnhValido = cnh != null && cnh.length() >= 11;
        
        Map<String, Object> response = new HashMap<>();
        response.put("cpf_valido", cpfValido);
        response.put("rg_valido", rgValido);
        response.put("cnh_valido", cnhValido);
        response.put("validacao_completa", cpfValido && rgValido && cnhValido);
        response.put("data_validacao", LocalDateTime.now().toString());
        
        return response;
    }
    
    /**
     * Validação básica de CPF (algoritmo real)
     */
    private boolean validarCpf(String cpf) {
        if (cpf == null || cpf.length() != 11) {
            return false;
        }
        
        // Remover caracteres não numéricos
        cpf = cpf.replaceAll("[^0-9]", "");
        
        if (cpf.length() != 11) {
            return false;
        }
        
        // Verificar se todos os dígitos são iguais
        if (cpf.matches("(\\d)\\1{10}")) {
            return false;
        }
        
        // Validar dígitos verificadores (algoritmo real do CPF)
        try {
            int[] digits = new int[11];
            for (int i = 0; i < 11; i++) {
                digits[i] = Integer.parseInt(cpf.substring(i, i + 1));
            }
            
            // Validar primeiro dígito verificador
            int sum = 0;
            for (int i = 0; i < 9; i++) {
                sum += digits[i] * (10 - i);
            }
            int firstDigit = 11 - (sum % 11);
            if (firstDigit >= 10) firstDigit = 0;
            if (firstDigit != digits[9]) {
                return false;
            }
            
            // Validar segundo dígito verificador
            sum = 0;
            for (int i = 0; i < 10; i++) {
                sum += digits[i] * (11 - i);
            }
            int secondDigit = 11 - (sum % 11);
            if (secondDigit >= 10) secondDigit = 0;
            if (secondDigit != digits[10]) {
                return false;
            }
            
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
