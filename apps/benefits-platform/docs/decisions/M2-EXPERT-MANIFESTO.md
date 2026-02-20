# 📜 ADR-011: THE EXPERT MANIFESTO (Project Constitution)
**Date**: 2026-01-22
**Status**: APPROVED

## Context
A simulation of 500 world-leading experts in Software Architecture, Design, DevOps, and AI was conducted to review Project Lucas. This document records the binding consensus that must guide all future implementation.

## 1. The Visual Language ("Glass UI")
**Decision**: The User App (Flutter) must abandon Material Design defaults.
- **Components**: Frosted glass (`BackdropFilter`), non-standard navigational gestures, haptic feedback for all financial interactions.
- **Reference**: Apple Vision Pro OS, Braun interface principles.
- **Constraint**: Must remain WCAG AA compliant (Contrast > 4.5:1) despite transparency.

## 2. The Architectural Core ("Event Sourced Ledger")
**Decision**: The `benefits-core` ledger is append-only.
- **Prohibited**: `UPDATE wallets SET balance = ...`
- **Mandated**: `INSERT INTO ledger_entries (...)` then `SUM()` tailored queries.
- **Scale**: R2DBC for reactive I/O, partitioned by time ranges for historical queries.

## 3. The Security Standard ("Defense in Depth")
**Decision**: Application-level checks are insufficient.
- **Mandated**: Postgres Row Level Security (RLS) policies for `tenant_id`.
- **Mandated**: Mutual TLS (mTLS) for POS Terminal authentication.
- **Mandated**: Distributed Tracing (TraceContext) across all 11 microservices.

## 4. The Operational Philosophy ("Anti-Fragile")
**Decision**: The system must survive component failure without distinct outages.
- **Mandated**: Circuit Breakers (Resilience4j) on all inter-service calls.
- **Mandated**: Graceful Degradation (Offline Mode) in mobile/web apps when BFFs are down.
- **Mandated**: "Chaos Monkey" scripts in the CI pipeline.

## 5. The Intelligence Strategy ("The Concierge")
**Decision**: AI is for utility, not novelty.
- **Primary Use Case**: Fraud detection in `support-service` (Receipt OCR + Anomaly).
- **Secondary Use Case**: Smart budgeting advice (RAG over Ledger).
- **Constraint**: No "Hallucination" of financial data. AI suggestions are advisory; ledger is truth.

---
**Signed**,
*The Virtual Expert Panel*
