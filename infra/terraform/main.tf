terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configuração do provider AWS apontando para LocalStack
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true

  endpoints {
    s3             = "http://localstack:4566"
    sqs            = "http://localstack:4566"
    sns            = "http://localstack:4566"
    secretsmanager = "http://localstack:4566"
    ssm            = "http://localstack:4566"
  }
}

# S3 Bucket para armazenar arquivos (comprovantes, etc)
resource "aws_s3_bucket" "benefits_storage" {
  bucket = "benefits-storage-local"
}

resource "aws_s3_bucket_versioning" "benefits_storage" {
  bucket = aws_s3_bucket.benefits_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# SQS Queue para processamento assíncrono
resource "aws_sqs_queue" "transaction_queue" {
  name                      = "benefits-transaction-queue"
  message_retention_seconds = 86400 # 24 horas
  visibility_timeout_seconds = 30
}

# SNS Topic para notificações
resource "aws_sns_topic" "notifications" {
  name = "benefits-notifications"
}

# SNS Topic para SMS (stub)
resource "aws_sns_topic" "sms" {
  name = "benefits-sms"
}

# Secrets Manager para credenciais
resource "aws_secretsmanager_secret" "sms_provider" {
  name = "benefits/sms-provider"
}

resource "aws_secretsmanager_secret_version" "sms_provider" {
  secret_id = aws_secretsmanager_secret.sms_provider.id
  secret_string = jsonencode({
    provider = "stub"
    endpoint = "http://user-bff:8080/sms/stub"
  })
}

# SSM Parameter para configurações
resource "aws_ssm_parameter" "sms_provider_config" {
  name  = "/benefits/sms/provider"
  type  = "String"
  value = "stub"
}

# SSM Parameter para ARN do tópico SMS
resource "aws_ssm_parameter" "sms_topic_arn" {
  name  = "/benefits/sms/topic-arn"
  type  = "String"
  value = aws_sns_topic.sms.arn
}
