#!/bin/bash

# Initialize LocalStack resources
# This script runs when LocalStack starts

echo "Initializing LocalStack resources..."

# Wait for LocalStack to be ready
sleep 5

# S3 Buckets
awslocal s3 mb s3://benefits-receipts
awslocal s3 mb s3://benefits-exports
awslocal s3 mb s3://benefits-settlements

# SQS Queues
awslocal sqs create-queue --queue-name benefits-wallet-events
awslocal sqs create-queue --queue-name benefits-payment-events
awslocal sqs create-queue --queue-name benefits-expense-events
awslocal sqs create-queue --queue-name benefits-dlq

# SNS Topics
awslocal sns create-topic --name benefits-events

# EventBridge Rules
awslocal events put-rule --name wallet-credit-rule --state ENABLED --event-pattern '{"source":["benefits"],"detail-type":["wallet.credited"]}'
awslocal events put-rule --name payment-authorized-rule --state ENABLED --event-pattern '{"source":["benefits"],"detail-type":["payment.authorized"]}'

echo "LocalStack initialization complete!"
