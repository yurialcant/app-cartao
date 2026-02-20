# Script para completar ApiService do Flutter com todos os métodos necessários

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     📱 COMPLETANDO API SERVICE DO FLUTTER 📱                   ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$apiServicePath = Join-Path $baseDir "apps/user_app_flutter/lib/services/api_service.dart"

if (-not (Test-Path $apiServicePath)) {
    Write-Host "  ✗ api_service.dart não encontrado" -ForegroundColor Red
    exit 1
}

$content = Get-Content $apiServicePath -Raw

# Métodos a adicionar
$newMethods = @"

  // ============================================
  // PAGAMENTOS QR
  // ============================================
  
  Future<Map<String, dynamic>> scanQR(String qrCode) async {
    try {
      debugPrint('🌐 [API] → POST /payments/qr/scan');
      final response = await _dio.post(
        '/payments/qr/scan',
        data: {'qrCode': qrCode},
      );
      debugPrint('🌐 [API] ✓ QR escaneado');
      return response.data;
    } catch (e) {
      debugPrint('🌐 [API] ✗ Erro ao escanear QR: \$e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> confirmQRPayment(String qrCode) async {
    try {
      debugPrint('🌐 [API] → POST /payments/qr/confirm');
      final response = await _dio.post(
        '/payments/qr/confirm',
        data: {'qrCode': qrCode},
      );
      debugPrint('🌐 [API] ✓ Pagamento QR confirmado');
      return response.data;
    } catch (e) {
      debugPrint('🌐 [API] ✗ Erro ao confirmar pagamento QR: \$e');
      rethrow;
    }
  }
  
  // ============================================
  // PAGAMENTOS CARTÃO
  // ============================================
  
  Future<Map<String, dynamic>> processCardPayment(String cardToken, double amount) async {
    try {
      debugPrint('🌐 [API] → POST /payments/card');
      final response = await _dio.post(
        '/payments/card',
        data: {
          'cardToken': cardToken,
          'amount': amount,
        },
      );
      debugPrint('🌐 [API] ✓ Pagamento cartão processado');
      return response.data;
    } catch (e) {
      debugPrint('🌐 [API] ✗ Erro ao processar pagamento cartão: \$e');
      rethrow;
    }
  }
  
  // ============================================
  // SEGURANÇA
  // ============================================
  
  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    try {
      debugPrint('🌐 [API] → GET /security/sessions');
      final response = await _dio.get('/security/sessions');
      debugPrint('🌐 [API] ✓ Sessões obtidas');
      return List<Map<String, dynamic>>.from(response.data['sessions'] ?? []);
    } catch (e) {
      debugPrint('🌐 [API] ✗ Erro ao buscar sessões: \$e');
      return [];
    }
  }
  
  Future<void> revokeSession(String sessionId) async {
    try {
      debugPrint('🌐 [API] → DELETE /security/sessions/\$sessionId');
      await _dio.delete('/security/sessions/\$sessionId');
      debugPrint('🌐 [API] ✓ Sessão revogada');
    } catch (e) {
      debugPrint('🌐 [API] ✗ Erro ao revogar sessão: \$e');
      rethrow;
    }
  }
  
  Future<void> activatePanicMode() async {
    try {
      debugPrint('🌐 [API] → POST /security/panic-mode');
      await _dio.post('/security/panic-mode');
      debugPrint('🌐 [API] ✓ Modo pânico ativado');
    } catch (e) {
      debugPrint('🌐 [API] ✗ Erro ao ativar modo pânico: \$e');
      rethrow;
    }
  }
  
  // ============================================
  // ATENDIMENTO
  // ============================================
  
  Future<List<Map<String, dynamic>>> getTickets() async {
    try {
      debugPrint('🌐 [API] → GET /support/tickets');
      final response = await _dio.get('/support/tickets');
      debugPrint('🌐 [API] ✓ Tickets obtidos');
      return List<Map<String, dynamic>>.from(response.data['tickets'] ?? []);
    } catch (e) {
      debugPrint('🌐 [API] ✗ Erro ao buscar tickets: \$e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>> createTicket(String subject, String description) async {
    try {
      debugPrint('🌐 [API] → POST /support/tickets');
      final response = await _dio.post(
        '/support/tickets',
        data: {
          'subject': subject,
          'description': description,
        },
      );
      debugPrint('🌐 [API] ✓ Ticket criado');
      return response.data;
    } catch (e) {
      debugPrint('🌐 [API] ✗ Erro ao criar ticket: \$e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> getTicket(String ticketId) async {
    try {
      debugPrint('🌐 [API] → GET /support/tickets/\$ticketId');
      final response = await _dio.get('/support/tickets/\$ticketId');
      debugPrint('🌐 [API] ✓ Ticket obtido');
      return response.data;
    } catch (e) {
      debugPrint('🌐 [API] ✗ Erro ao buscar ticket: \$e');
      rethrow;
    }
  }
  
  // ============================================
  // LGPD
  // ============================================
  
  Future<Map<String, dynamic>> exportData() async {
    try {
      debugPrint('🌐 [API] → POST /privacy/export');
      final response = await _dio.post('/privacy/export');
      debugPrint('🌐 [API] ✓ Exportação iniciada');
      return response.data;
    } catch (e) {
      debugPrint('🌐 [API] ✗ Erro ao exportar dados: \$e');
      rethrow;
    }
  }
  
  Future<void> deleteData() async {
    try {
      debugPrint('🌐 [API] → POST /privacy/delete');
      await _dio.post('/privacy/delete');
      debugPrint('🌐 [API] ✓ Exclusão iniciada');
    } catch (e) {
      debugPrint('🌐 [API] ✗ Erro ao excluir dados: \$e');
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> getConsents() async {
    try {
      debugPrint('🌐 [API] → GET /privacy/consents');
      final response = await _dio.get('/privacy/consents');
      debugPrint('🌐 [API] ✓ Consentimentos obtidos');
      return List<Map<String, dynamic>>.from(response.data['consents'] ?? []);
    } catch (e) {
      debugPrint('🌐 [API] ✗ Erro ao buscar consentimentos: \$e');
      return [];
    }
  }
"@

# Verificar se métodos já existem
if ($content -match "confirmQRPayment|processCardPayment|getActiveSessions") {
    Write-Host "  ⚠ Métodos já existem parcialmente" -ForegroundColor Yellow
    # Adicionar apenas métodos faltantes
} else {
    # Adicionar antes do último }
    $lastBrace = $content.LastIndexOf('}')
    $newContent = $content.Insert($lastBrace, $newMethods)
    Set-Content -Path $apiServicePath -Value $newContent -Encoding UTF8
    Write-Host "  ✓ Métodos adicionados ao ApiService" -ForegroundColor Green
}

Write-Host "`n✅ ApiService do Flutter completado!" -ForegroundColor Green
Write-Host ""
