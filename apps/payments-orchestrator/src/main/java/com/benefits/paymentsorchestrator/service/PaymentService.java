package com.benefits.paymentsorchestrator.service;

import com.benefits.paymentsorchestrator.client.AcquirerAdapterClient;
import com.benefits.paymentsorchestrator.client.CoreServiceClient;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Service
public class PaymentService {

    private static final Logger log = LoggerFactory.getLogger(PaymentService.class);

    private final CoreServiceClient coreServiceClient;
    private final AcquirerAdapterClient acquirerAdapterClient;
    private final IdempotencyService idempotencyService;

    @Value("${core.service.api-key}")
    private String apiKey;

    public PaymentService(CoreServiceClient coreServiceClient, AcquirerAdapterClient acquirerAdapterClient, IdempotencyService idempotencyService) {
        this.coreServiceClient = coreServiceClient;
        this.acquirerAdapterClient = acquirerAdapterClient;
        this.idempotencyService = idempotencyService;
    }

    public Map<String, Object> createQRPayment(UUID merchantId, BigDecimal amount, String tenantId, String idempotencyKey) {
        log.info("🔵 [PAYMENTS-ORCHESTRATOR] Criando pagamento QR - merchantId: {}, amount: {}, tenantId: {}", merchantId, amount, tenantId);

        // Verificar idempotência
        if (idempotencyKey != null && idempotencyService.isProcessed(idempotencyKey)) {
            log.info("🔵 [PAYMENTS-ORCHESTRATOR] Retornando resultado idempotente para chave: {}", idempotencyKey);
            return idempotencyService.getResult(idempotencyKey);
        }

        // Criar ChargeIntent no Core Service
        Map<String, Object> chargeIntentRequest = Map.of(
            "merchantId", merchantId,
            "terminalId", UUID.randomUUID(), // TODO: get from context
            "operatorId", UUID.randomUUID(), // TODO: get from context
            "amount", amount,
            "currency", "BRL",
            "expiresInMinutes", 15
        );

        log.info("🔵 [PAYMENTS-ORCHESTRATOR] Chamando benefits-core para criar ChargeIntent: {}", chargeIntentRequest);
        Map<String, Object> chargeIntent = coreServiceClient.createChargeIntent(chargeIntentRequest, apiKey, tenantId, null);
        log.info("🔵 [PAYMENTS-ORCHESTRATOR] ChargeIntent criado com sucesso: {}", chargeIntent);

        Map<String, Object> result = Map.of(
            "chargeIntentId", chargeIntent.get("id"),
            "qrCode", chargeIntent.get("qrCode") != null ? chargeIntent.get("qrCode") : "QR_" + chargeIntent.get("id").toString().substring(0, 8).toUpperCase(),
            "amount", amount,
            "expiresAt", chargeIntent.get("expiresAt") != null ? chargeIntent.get("expiresAt") : java.time.LocalDateTime.now().plusMinutes(15).toString(),
            "status", "PENDING"
        );

        // Armazenar resultado para idempotência
        if (idempotencyKey != null) {
            idempotencyService.storeResult(idempotencyKey, result);
        }

        return result;
    }

    public Map<String, Object> confirmQRPayment(UUID chargeIntentId, String userId, String tenantId, String idempotencyKey) {
        log.info("🔵 [PAYMENTS-ORCHESTRATOR] Confirmando pagamento QR - chargeIntentId: {}, userId: {}", chargeIntentId, userId);

        // Verificar idempotência
        if (idempotencyKey != null && idempotencyService.isProcessed(idempotencyKey)) {
            return idempotencyService.getResult(idempotencyKey);
        }

        // Confirmar ChargeIntent
        Map<String, Object> confirmedChargeIntent = coreServiceClient.confirmChargeIntent(chargeIntentId, apiKey, tenantId, null);

        BigDecimal amount = new BigDecimal(confirmedChargeIntent.get("amount").toString());
        UUID paymentId = UUID.randomUUID();

        // Criar Payment no Core Service
        Map<String, Object> paymentRequest = Map.of(
            "transactionId", UUID.randomUUID(),
            "chargeIntentId", chargeIntentId,
            "userId", userId,
            "merchantId", confirmedChargeIntent.get("merchantId"),
            "amount", amount,
            "currency", "BRL",
            "paymentMethod", "QR_CODE"
        );

        Map<String, Object> payment = coreServiceClient.createPayment(paymentRequest, apiKey, tenantId, null);

        Map<String, Object> result = Map.of(
            "paymentId", payment.get("id"),
            "chargeIntentId", chargeIntentId,
            "status", "AUTHORIZED",
            "amount", amount,
            "processedAt", LocalDateTime.now().toString()
        );

        if (idempotencyKey != null) {
            idempotencyService.storeResult(idempotencyKey, result);
        }

        return result;
    }

    public Map<String, Object> processCardPayment(UUID merchantId, String cardToken, BigDecimal amount, String tenantId, String idempotencyKey) {
        log.info("🔵 [PAYMENTS-ORCHESTRATOR] Processando pagamento cartão - merchantId: {}, amount: {}", merchantId, amount);

        // Verificar idempotência
        if (idempotencyKey != null && idempotencyService.isProcessed(idempotencyKey)) {
            return idempotencyService.getResult(idempotencyKey);
        }

        // Chamar Acquirer Adapter para autorização
        Map<String, Object> authRequest = Map.of(
            "merchantId", merchantId.toString(),
            "cardToken", cardToken,
            "amount", amount,
            "currency", "BRL"
        );

        Map<String, Object> authResponse = acquirerAdapterClient.authorize(authRequest, null);

        String authStatus = (String) authResponse.get("status");
        UUID paymentId = UUID.randomUUID();

        if ("APPROVED".equals(authStatus)) {
            // Criar Payment no Core Service
            Map<String, Object> paymentRequest = Map.of(
                "transactionId", UUID.randomUUID(),
                "userId", "card_payment", // TODO: get from context
                "merchantId", merchantId,
                "amount", amount,
                "currency", "BRL",
                "paymentMethod", "CARD",
                "acquirerReference", authResponse.get("reference"),
                "authorizationCode", authResponse.get("authCode")
            );

            coreServiceClient.createPayment(paymentRequest, apiKey, tenantId, null);
        }

        Map<String, Object> result = Map.of(
            "paymentId", paymentId.toString(),
            "status", authStatus,
            "authCode", authResponse.get("authCode"),
            "processedAt", LocalDateTime.now().toString()
        );

        if (idempotencyKey != null) {
            idempotencyService.storeResult(idempotencyKey, result);
        }

        return result;
    }

    public Map<String, Object> getPaymentStatus(UUID paymentId, String tenantId) {
        log.info("🔵 [PAYMENTS-ORCHESTRATOR] Buscando status - paymentId: {}", paymentId);
        return coreServiceClient.getPayment(paymentId, apiKey, tenantId, null);
    }
}
