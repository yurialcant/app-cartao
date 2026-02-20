package com.benefits.userbff.dto;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExportJobDto {
    private String jobId;

    // Getters and setters for compatibility
    public String getJobId() { return jobId; }
    public void setJobId(String jobId) { this.jobId = jobId; }
}