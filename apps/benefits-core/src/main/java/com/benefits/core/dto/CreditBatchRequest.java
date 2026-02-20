package com.benefits.core.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.math.BigDecimal;
import java.util.List;

public class CreditBatchRequest {
    @JsonProperty("batch_reference")
    private String batchReference;

    @JsonProperty("items")
    private List<CreditBatchItemRequest> items;

    // Constructors
    public CreditBatchRequest() {}

    public CreditBatchRequest(String batchReference, List<CreditBatchItemRequest> items) {
        this.batchReference = batchReference;
        this.items = items;
    }

    // Getters and Setters
    public String getBatchReference() { return batchReference; }
    public void setBatchReference(String batchReference) { this.batchReference = batchReference; }

    public List<CreditBatchItemRequest> getItems() { return items; }
    public void setItems(List<CreditBatchItemRequest> items) { this.items = items; }

    public static class CreditBatchItemRequest {
        @JsonProperty("person_id")
        private String personId;

        @JsonProperty("wallet_id")
        private String walletId;

        @JsonProperty("amount")
        private BigDecimal amount;

        @JsonProperty("description")
        private String description;

        // Constructors
        public CreditBatchItemRequest() {}

        public CreditBatchItemRequest(String personId, String walletId, BigDecimal amount, String description) {
            this.personId = personId;
            this.walletId = walletId;
            this.amount = amount;
            this.description = description;
        }

        // Getters and Setters
        public String getPersonId() { return personId; }
        public void setPersonId(String personId) { this.personId = personId; }

        public String getWalletId() { return walletId; }
        public void setWalletId(String walletId) { this.walletId = walletId; }

        public BigDecimal getAmount() { return amount; }
        public void setAmount(BigDecimal amount) { this.amount = amount; }

        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
    }
}