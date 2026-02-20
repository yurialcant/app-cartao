package com.benefits.kybservice.provider;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

/**
 * Stub baseado na API real do ReceitaWS
 * Documentação: https://www.receitaws.com.br/
 * 
 * Este stub imita a estrutura de resposta da API real do ReceitaWS para consulta de CNPJ.
 */
@Slf4j
@Component
public class ReceitaWsKybProvider {
    
    private final Random random = new Random();
    
    /**
     * Consultar CNPJ baseado na API real do ReceitaWS
     * Endpoint real: GET /v1/cnpj/{cnpj}
     */
    public Map<String, Object> consultarCnpj(String cnpj) {
        log.info("🔵 [RECEITAWS-STUB] Consultando CNPJ - CNPJ: {}", cnpj);
        
        // Simular validação básica de CNPJ
        boolean isValid = validarCnpj(cnpj);
        
        Map<String, Object> response = new HashMap<>();
        response.put("cnpj", cnpj);
        response.put("nome", isValid ? "Empresa Teste LTDA" : null);
        response.put("fantasia", isValid ? "Empresa Teste" : null);
        response.put("situacao", isValid ? "ATIVA" : "INATIVA");
        response.put("abertura", isValid ? "2010-01-01" : null);
        response.put("tipo", isValid ? "MATRIZ" : null);
        response.put("porte", isValid ? "DEMAIS" : null);
        response.put("natureza_juridica", isValid ? "2062 - Sociedade Empresária Limitada" : null);
        
        if (isValid) {
            Map<String, Object> atividadePrincipal = new HashMap<>();
            atividadePrincipal.put("code", "47.11-1-00");
            atividadePrincipal.put("text", "Comércio varejista de mercadorias em geral");
            response.put("atividade_principal", List.of(atividadePrincipal));
            
            Map<String, Object> endereco = new HashMap<>();
            endereco.put("logradouro", "Rua Teste");
            endereco.put("numero", "123");
            endereco.put("complemento", "Sala 45");
            endereco.put("bairro", "Centro");
            endereco.put("municipio", "São Paulo");
            endereco.put("uf", "SP");
            endereco.put("cep", "01000-000");
            response.put("endereco", endereco);
            
            Map<String, Object> contato = new HashMap<>();
            contato.put("telefone", "(11) 9999-9999");
            contato.put("email", "contato@empresateste.com.br");
            response.put("contato", contato);
        }
        
        response.put("data_consulta", LocalDateTime.now().toString());
        
        return response;
    }
    
    /**
     * Validação básica de CNPJ (algoritmo real)
     */
    private boolean validarCnpj(String cnpj) {
        if (cnpj == null || cnpj.length() != 14) {
            return false;
        }
        
        // Remover caracteres não numéricos
        cnpj = cnpj.replaceAll("[^0-9]", "");
        
        if (cnpj.length() != 14) {
            return false;
        }
        
        // Verificar se todos os dígitos são iguais
        if (cnpj.matches("(\\d)\\1{13}")) {
            return false;
        }
        
        // Validar dígitos verificadores (algoritmo real do CNPJ)
        try {
            int[] digits = new int[14];
            for (int i = 0; i < 14; i++) {
                digits[i] = Integer.parseInt(cnpj.substring(i, i + 1));
            }
            
            // Validar primeiro dígito verificador
            int[] weights1 = {5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2};
            int sum = 0;
            for (int i = 0; i < 12; i++) {
                sum += digits[i] * weights1[i];
            }
            int firstDigit = sum % 11 < 2 ? 0 : 11 - (sum % 11);
            if (firstDigit != digits[12]) {
                return false;
            }
            
            // Validar segundo dígito verificador
            int[] weights2 = {6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2};
            sum = 0;
            for (int i = 0; i < 13; i++) {
                sum += digits[i] * weights2[i];
            }
            int secondDigit = sum % 11 < 2 ? 0 : 11 - (sum % 11);
            if (secondDigit != digits[13]) {
                return false;
            }
            
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
