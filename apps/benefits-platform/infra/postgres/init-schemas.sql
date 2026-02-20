-- Initialize PostgreSQL schemas for all services
-- This script is run automatically on container startup

CREATE SCHEMA IF NOT EXISTS public;
CREATE SCHEMA IF NOT EXISTS tenant_service;
CREATE SCHEMA IF NOT EXISTS benefits_core;
CREATE SCHEMA IF NOT EXISTS payments;
CREATE SCHEMA IF NOT EXISTS support;
CREATE SCHEMA IF NOT EXISTS merchant;
CREATE SCHEMA IF NOT EXISTS recon;
CREATE SCHEMA IF NOT EXISTS settlement;
CREATE SCHEMA IF NOT EXISTS audit;
CREATE SCHEMA IF NOT EXISTS ops;

-- UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- JSON is built-in to PostgreSQL 15, no need to create extension
