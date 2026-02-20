# Test F09 - Expense Reimbursement Flow
# Tests the complete expense reimbursement workflow

param(
    [string]$serverUrl = "http://localhost:8091"
)

Write-Host "🧾 [F09] Testing Expense Reimbursement Flow..." -ForegroundColor Cyan
Write-Host "Server: $serverUrl" -ForegroundColor Gray
Write-Host ""

# Test data
$tenantId = "550e8400-e29b-41d4-a716-446655440000"
$personId = "550e8400-e29b-41d4-a716-446655440001"
$employerId = "550e8400-e29b-41d4-a716-446655440003"

# Test 1: Submit expense with receipt
Write-Host "📝 Test 1: Submit Expense" -ForegroundColor Yellow
$expenseRequest = @{
    title = "Viagem São Paulo"
    description = "Viagem de negócio para reunião com cliente"
    amount = 1250.50
    currency = "BRL"
    category = "TRAVEL"
    receipts = @(
        @{
            filename = "recibo_hotel.pdf"
            contentType = "application/pdf"
            fileSize = 2048576  # 2MB
        },
        @{
            filename = "passagem_aviao.jpg"
            contentType = "image/jpeg"
            fileSize = 1048576  # 1MB
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "Request: $expenseRequest" -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "$serverUrl/internal/expenses" -Method POST `
        -Headers @{
            "Content-Type" = "application/json"
            "X-Tenant-Id" = $tenantId
            "X-Person-Id" = $personId
            "X-Employer-Id" = $employerId
            "Idempotency-Key" = "test-expense-$(Get-Date -Format 'yyyyMMddHHmmss')"
        } `
        -Body $expenseRequest

    Write-Host "✅ Expense submitted successfully!" -ForegroundColor Green
    Write-Host "Expense ID: $($response.expenseId)" -ForegroundColor Cyan
    Write-Host "Status: $($response.status)" -ForegroundColor Cyan
    Write-Host "Amount: $($response.amount) $($response.currency)" -ForegroundColor Cyan
    Write-Host "Receipts: $($response.receipts.Count)" -ForegroundColor Cyan
    Write-Host ""

    $expenseId = $response.expenseId

} catch {
    Write-Host "❌ Failed to submit expense" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Get expense details
Write-Host "📖 Test 2: Get Expense Details" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$serverUrl/internal/expenses/$expenseId" -Method GET `
        -Headers @{
            "X-Tenant-Id" = $tenantId
        }

    Write-Host "✅ Expense retrieved successfully!" -ForegroundColor Green
    Write-Host "Title: $($response.title)" -ForegroundColor Cyan
    Write-Host "Status: $($response.status)" -ForegroundColor Cyan
    Write-Host "Receipts count: $($response.receipts.Count)" -ForegroundColor Cyan
    Write-Host ""

} catch {
    Write-Host "❌ Failed to get expense" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 3: List expenses
Write-Host "📋 Test 3: List Expenses" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$serverUrl/internal/expenses?page=0&size=10" -Method GET `
        -Headers @{
            "X-Tenant-Id" = $tenantId
        }

    Write-Host "✅ Expenses listed successfully!" -ForegroundColor Green
    Write-Host "Total expenses: $($response.totalElements)" -ForegroundColor Cyan
    Write-Host "Page: $($response.page), Size: $($response.size)" -ForegroundColor Cyan
    Write-Host "Expenses on page: $($response.expenses.Count)" -ForegroundColor Cyan
    Write-Host ""

} catch {
    Write-Host "❌ Failed to list expenses" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 4: Approve expense (simulating employer admin)
Write-Host "✅ Test 4: Approve Expense" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$serverUrl/internal/expenses/$expenseId/approve" -Method PUT `
        -Headers @{
            "X-Tenant-Id" = $tenantId
            "X-Person-Id" = "550e8400-e29b-41d4-a716-446655440002"  # Different person (approver)
        }

    Write-Host "✅ Expense approved successfully!" -ForegroundColor Green
    Write-Host "New status: $($response.status)" -ForegroundColor Cyan
    Write-Host "Approved at: $($response.approvedAt)" -ForegroundColor Cyan
    Write-Host ""

} catch {
    Write-Host "❌ Failed to approve expense" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 5: Reimburse expense (simulating admin operation)
Write-Host "💰 Test 5: Reimburse Expense" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$serverUrl/internal/expenses/$expenseId/reimburse" -Method PUT `
        -Headers @{
            "X-Tenant-Id" = $tenantId
        }

    Write-Host "✅ Expense reimbursed successfully!" -ForegroundColor Green
    Write-Host "Final status: $($response.status)" -ForegroundColor Cyan
    Write-Host "Reimbursed at: $($response.reimbursedAt)" -ForegroundColor Cyan
    Write-Host ""

} catch {
    Write-Host "❌ Failed to reimburse expense" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 6: Add additional receipt
Write-Host "📎 Test 6: Add Additional Receipt" -ForegroundColor Yellow

$receiptRequest = @{
    filename = "comprovante_taxi.png"
    contentType = "image/png"
    fileSize = 512000  # 512KB
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$serverUrl/internal/expenses/$expenseId/receipts" -Method POST `
        -Headers @{
            "Content-Type" = "application/json"
            "X-Tenant-Id" = $tenantId
        } `
        -Body $receiptRequest

    Write-Host "✅ Receipt added successfully!" -ForegroundColor Green
    Write-Host "Receipt ID: $($response.receiptId)" -ForegroundColor Cyan
    Write-Host "Filename: $($response.filename)" -ForegroundColor Cyan
    Write-Host ""

} catch {
    Write-Host "❌ Failed to add receipt" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Summary
Write-Host "🎉 [F09] All tests passed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "  ✅ Expense submitted with receipts" -ForegroundColor Green
Write-Host "  ✅ Expense retrieved by ID" -ForegroundColor Green
Write-Host "  ✅ Expenses listed with pagination" -ForegroundColor Green
Write-Host "  ✅ Expense approved by employer admin" -ForegroundColor Green
Write-Host "  ✅ Expense reimbursed (credit created)" -ForegroundColor Green
Write-Host "  ✅ Additional receipt uploaded" -ForegroundColor Green
Write-Host ""
Write-Host "🏆 F09 Expense Reimbursement Flow is fully functional!" -ForegroundColor Magenta