package com.benefits.core.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.List;

public class CreditBatchResponse {
    @JsonProperty("id")
    private String id;

    @JsonProperty("batch_reference")
    private String batchReference;

    @JsonProperty("status")
    private String status;

    @JsonProperty("items_total")
    private Integer itemsTotal;

    @JsonProperty("items_succeeded")
    private Integer itemsSucceeded;

    @JsonProperty("items_failed")
    private Integer itemsFailed;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;

    @JsonProperty("items")
    private List<BatchItemResult> items;

    // Constructors
    public CreditBatchResponse() {}

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getBatchReference() { return batchReference; }
    public void setBatchReference(String batchReference) { this.batchReference = batchReference; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Integer getItemsTotal() { return itemsTotal; }
    public void setItemsTotal(Integer itemsTotal) { this.itemsTotal = itemsTotal; }

    public Integer getItemsSucceeded() { return itemsSucceeded; }
    public void setItemsSucceeded(Integer itemsSucceeded) { this.itemsSucceeded = itemsSucceeded; }

    public Integer getItemsFailed() { return itemsFailed; }
    public void setItemsFailed(Integer itemsFailed) { this.itemsFailed = itemsFailed; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }

    public List<BatchItemResult> getItems() { return items; }
    public void setItems(List<BatchItemResult> items) { this.items = items; }

    public static class BatchItemResult {
        @JsonProperty("person_id")
        private String personId;

        @JsonProperty("wallet_id")
        private String walletId;

        @JsonProperty("amount")
        private java.math.BigDecimal amount;

        @JsonProperty("status")
        private String status;

        @JsonProperty("ledger_entry_id")
        private String ledgerEntryId;

        @JsonProperty("error_message")
        private String errorMessage;

        // Constructors
        public BatchItemResult() {}

        // Getters and Setters
        public String getPersonId() { return personId; }
        public void setPersonId(String personId) { this.personId = personId; }

        public String getWalletId() { return walletId; }
        public void setWalletId(String walletId) { this.walletId = walletId; }

        public java.math.BigDecimal getAmount() { return amount; }
        public void setAmount(java.math.BigDecimal amount) { this.amount = amount; }

        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }

        public String getLedgerEntryId() { return ledgerEntryId; }
        public void setLedgerEntryId(String ledgerEntryId) { this.ledgerEntryId = ledgerEntryId; }

        public String getErrorMessage() { return errorMessage; }
        public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
    }
}