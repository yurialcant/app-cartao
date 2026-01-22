#!/usr/bin/env python3
"""
Test Credit Batch API
"""

import requests
import json
import uuid
from datetime import datetime

def test_credit_batch_submit():
    url = "http://localhost:8084/internal/batches/credits"

    headers = {
        "Content-Type": "application/json",
        "X-Tenant-Id": "550e8400-e29b-41d4-a716-446655440000",
        "X-Employer-Id": "550e8400-e29b-41d4-a716-446655440001",
        "X-Idempotency-Key": str(uuid.uuid4()),
        "X-Correlation-Id": str(uuid.uuid4())
    }

    payload = {
        "batch_name": "Test Batch",
        "items": [
            {
                "user_id": "550e8400-e29b-41d4-a716-446655440002",
                "amount_cents": 10000,
                "description": "Test credit"
            }
        ]
    }

    try:
        print("🧪 Testing Credit Batch Submit...")
        response = requests.post(url, headers=headers, json=payload, timeout=10)
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")

        if response.status_code == 201:
            print("✅ Credit batch submitted successfully!")
            return True
        else:
            print("❌ Failed to submit credit batch")
            return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_credit_batch_list():
    url = "http://localhost:8084/internal/batches/credits"

    headers = {
        "X-Tenant-Id": "550e8400-e29b-41d4-a716-446655440000",
        "X-Correlation-Id": str(uuid.uuid4())
    }

    try:
        print("🧪 Testing Credit Batch List...")
        response = requests.get(url, headers=headers, timeout=10)
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")

        if response.status_code == 200:
            print("✅ Credit batch list retrieved successfully!")
            return True
        else:
            print("❌ Failed to list credit batches")
            return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    print("🔥 Testing Credit Batch API")
    print("=" * 50)

    success_count = 0
    total_tests = 2

    if test_credit_batch_submit():
        success_count += 1

    if test_credit_batch_list():
        success_count += 1

    print("=" * 50)
    print(f"Results: {success_count}/{total_tests} tests passed")
    if success_count == total_tests:
        print("🎉 All tests passed!")
    else:
        print("⚠️  Some tests failed")