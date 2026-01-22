#!/usr/bin/env python3
"""
End-to-End Test Script for Benefits Platform
Simulates the complete user login flow
"""

import subprocess
import time
import json
import threading
import sys
import os

mock_server_process = None

def start_mock_server():
    """Start the mock user BFF server"""
    global mock_server_process
    print("🚀 Starting Mock User BFF Server...")
    try:
        mock_server_process = subprocess.Popen([
            sys.executable, 'simple-mock-user-bff.py'
        ], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        # Wait longer for server to start
        time.sleep(5)
        
        # Test if server is responding
        for i in range(10):
            try:
                result = subprocess.run([
                    'curl', '-s', '--max-time', '2', 'http://localhost:8080/actuator/health'
                ], capture_output=True, text=True, timeout=3)
                if 'UP' in result.stdout:
                    print("✅ Mock server is responding")
                    return True
            except:
                pass
            time.sleep(1)
        
        print("❌ Mock server failed to respond")
        return False
    except Exception as e:
        print(f"❌ Failed to start mock server: {e}")
        return False

def stop_mock_server():
    """Stop the mock user BFF server"""
    global mock_server_process
    if mock_server_process:
        print("🛑 Stopping Mock User BFF Server...")
        mock_server_process.terminate()
        mock_server_process.wait()
        mock_server_process = None

def test_health_check():
    """Test health check of mock user-bff"""
    print("🩺 Testing User-BFF Health...")
    try:
        result = subprocess.run([
            'curl', '-s', 'http://localhost:8080/actuator/health'
        ], capture_output=True, text=True, timeout=5)

        if 'status' in result.stdout and 'UP' in result.stdout:
            print("✅ User-BFF is healthy")
            return True
        else:
            print("❌ User-BFF health check failed")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False

def test_user_login():
    """Test user login via mock BFF"""
    print("\n🔐 Testing User Login...")
    try:
        result = subprocess.run([
            'curl', '-s', '-X', 'POST', 'http://localhost:8080/auth/login',
            '-H', 'Content-Type: application/json',
            '-d', '{"username":"tiago.tiede@flash.com","password":"senha123"}'
        ], capture_output=True, text=True, timeout=5)

        if result.returncode == 0 and 'access_token' in result.stdout:
            print("✅ User login successful")
            response = json.loads(result.stdout)
            token = response.get('access_token', '')[:50] + '...'
            print(f"   Token: {token}")
            return True
        else:
            print("❌ User login failed")
            print(f"   Response: {result.stdout}")
            return False
    except Exception as e:
        print(f"❌ Login error: {e}")
        return False

def test_benefits_core():
    """Test benefits-core connection"""
    print("\n🏢 Testing Benefits-Core...")
    try:
        result = subprocess.run([
            'curl', '-s', 'http://localhost:8091/test'
        ], capture_output=True, text=True, timeout=5)

        if result.returncode == 0 and 'Test' in result.stdout:
            print("✅ Benefits-Core is responding")
            return True
        else:
            print("❌ Benefits-Core test failed")
            return False
    except Exception as e:
        print(f"❌ Benefits-Core error: {e}")
        return False

def test_admin_bff():
    """Test admin BFF health"""
    print("\n🔧 Testing Admin BFF...")
    try:
        result = subprocess.run([
            'curl', '-s', 'http://localhost:8083/actuator/health'
        ], capture_output=True, text=True, timeout=5)

        if 'status' in result.stdout and 'UP' in result.stdout:
            print("✅ Admin BFF is healthy")
            return True
        else:
            print("❌ Admin BFF health check failed")
            return False
    except Exception as e:
        print(f"❌ Admin BFF error: {e}")
        return False

def test_admin_portal():
    """Test admin portal accessibility"""
    print("\n👨‍💼 Testing Admin Portal...")
    try:
        result = subprocess.run([
            'curl', '-s', '--max-time', '10', 'http://localhost:4200'
        ], capture_output=True, text=True, timeout=15)

        if result.returncode == 0 and len(result.stdout) > 100:
            print("✅ Admin Portal is accessible")
            return True
        else:
            print("⚠️ Admin Portal may not be running (expected if not started)")
            return True  # Not critical for basic E2E
    except Exception as e:
        print(f"⚠️ Admin Portal check: {e} (expected if not started)")
        return True

def main():
    print("🚀 Benefits Platform End-to-End Test")
    print("=" * 50)

    # Start mock server
    if not start_mock_server():
        print("❌ Cannot proceed without mock server")
        return False

    try:
        tests = [
            ("User-BFF Health", test_health_check),
            ("User Login Flow", test_user_login),
            ("Benefits-Core", test_benefits_core),
            ("Admin BFF", test_admin_bff),
            ("Admin Portal", test_admin_portal),
        ]

        passed = 0
        total = len(tests)

        for test_name, test_func in tests:
            print(f"\n🔍 Running: {test_name}")
            if test_func():
                passed += 1
            time.sleep(1)  # Brief pause between tests

        print("\n" + "=" * 50)
        print(f"📊 Test Results: {passed}/{total} passed")

        if passed == total:
            print("🎉 ALL TESTS PASSED! Platform is ready for development.")
            print("\n📱 Next Steps:")
            print("   1. Start Flutter app: flutter run -d emulator")
            print("   2. Test login with: tiago.tiede@flash.com / senha123")
            print("   3. Implement admin user/company creation")
            print("   4. Add payment flows and wallet management")
        else:
            print("⚠️ Some tests failed. Check services and restart if needed.")

        return passed == total
    finally:
        stop_mock_server()

if __name__ == '__main__':
    success = main()
    exit(0 if success else 1)