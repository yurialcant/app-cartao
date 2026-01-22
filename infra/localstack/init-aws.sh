#!/bin/bash
# LocalStack initialization script
# Creates S3 buckets, SQS queues, EventBridge bus, etc.

set -e

echo "Initializing LocalStack resources..."

# Wait for LocalStack to be ready
awslocal s3 ls 2>/dev/null || sleep 5

# Create S3 buckets
echo "Creating S3 buckets..."
awslocal s3 mb s3://benefits-receipts --region us-east-1
awslocal s3 mb s3://benefits-exports --region us-east-1
awslocal s3 mb s3://benefits-backups --region us-east-1

# Create SQS queues
echo "Creating SQS queues..."
PAYMENTS_QUEUE=$(awslocal sqs create-queue --queue-name payments-events --region us-east-1 --output text --query QueueUrl)
WALLETS_QUEUE=$(awslocal sqs create-queue --queue-name wallet-events --region us-east-1 --output text --query QueueUrl)
AUDIT_QUEUE=$(awslocal sqs create-queue --queue-name audit-events --region us-east-1 --output text --query QueueUrl)

# Create DLQ for failed messages
echo "Creating DLQ..."
DLQ=$(awslocal sqs create-queue --queue-name payments-events-dlq --region us-east-1 --output text --query QueueUrl)

# Create EventBridge event bus
echo "Creating EventBridge event bus..."
awslocal events create-event-bus --name benefits-events --region us-east-1

echo "LocalStack resources initialized successfully!"
