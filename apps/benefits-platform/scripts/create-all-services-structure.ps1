# Script para criar estrutura completa de todos os serviços necessários
# para implementar os 15 fluxos E2E completos

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🏗️  CRIANDO ESTRUTURA COMPLETA DE SERVIÇOS 🏗️            ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$servicesDir = Join-Path $baseDir "services"

# Serviços especializados a criar
$services = @(
    @{Name="payments-orchestrator"; Port=8092; Description="Orquestração de pagamentos QR e Cartão"},
    @{Name="acquirer-adapter"; Port=8093; Description="Adaptadores para adquirentes (Cielo, Stone)"},
    @{Name="risk-service"; Port=8094; Description="Análise de risco e step-up MFA"},
    @{Name="support-service"; Port=8095; Description="Gestão de tickets e atendimento"},
    @{Name="settlement-service"; Port=8096; Description="Cálculo de repasses e settlement"},
    @{Name="recon-service"; Port=8097; Description="Reconciliação de extratos"},
    @{Name="device-service"; Port=8098; Description="Registro e validação de dispositivos"},
    @{Name="audit-service"; Port=8099; Description="Logging de auditoria e compliance"},
    @{Name="notification-service"; Port=8100; Description="Push, Email, SMS"},
    @{Name="kyc-service"; Port=8101; Description="Validação KYC de usuários"},
    @{Name="kyb-service"; Port=8102; Description="Validação KYB de merchants"},
    @{Name="privacy-service"; Port=8103; Description="LGPD e privacidade"}
)

# Stubs para serviços externos
$stubs = @(
    @{Name="acquirer-stub"; Port=8104; Description="Stub para APIs de adquirentes"},
    @{Name="webhook-receiver"; Port=8105; Description="Receptor de webhooks"}
)

function Create-Service-Structure {
    param(
        [string]$ServiceName,
        [int]$Port,
        [string]$Description
    )
    
    Write-Host "  Criando $ServiceName (porta $Port)..." -ForegroundColor Yellow
    
    $serviceDir = Join-Path $servicesDir $ServiceName
    
    # Criar estrutura de diretórios
    $dirs = @(
        "src/main/java/com/benefits/$($ServiceName.Replace('-', ''))",
        "src/main/java/com/benefits/$($ServiceName.Replace('-', ''))/controller",
        "src/main/java/com/benefits/$($ServiceName.Replace('-', ''))/service",
        "src/main/java/com/benefits/$($ServiceName.Replace('-', ''))/config",
        "src/main/resources",
        "src/test/java/com/benefits/$($ServiceName.Replace('-', ''))"
    )
    
    foreach ($dir in $dirs) {
        $fullPath = Join-Path $serviceDir $dir
        if (-not (Test-Path $fullPath)) {
            New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        }
    }
    
    # Criar pom.xml básico
    $pomContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.5.9</version>
        <relativePath/>
    </parent>
    
    <groupId>com.benefits</groupId>
    <artifactId>$ServiceName</artifactId>
    <version>1.0.0</version>
    <name>$Description</name>
    
    <properties>
        <java.version>21</java.version>
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
"@
    
    $pomPath = Join-Path $serviceDir "pom.xml"
    if (-not (Test-Path $pomPath)) {
        Set-Content -Path $pomPath -Value $pomContent -Encoding UTF8
    }
    
    # Criar Application.java
    $packageName = $ServiceName.Replace('-', '')
    $className = ($packageName -split '-' | ForEach-Object { 
        $_.Substring(0,1).ToUpper() + $_.Substring(1) 
    }) -join ''
    $className = ($className -split '-' | ForEach-Object { 
        $_.Substring(0,1).ToUpper() + $_.Substring(1) 
    }) -join ''
    
    # Simplificar nome da classe
    $simpleName = ($ServiceName -split '-' | ForEach-Object { 
        $_.Substring(0,1).ToUpper() + $_.Substring(1) 
    }) -join '' | ForEach-Object { $_ -replace 'Service$', '' }
    $simpleName = $simpleName + "Application"
    
    $appContent = @"
package com.benefits.$packageName;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class $simpleName {
    public static void main(String[] args) {
        SpringApplication.run($simpleName.class, args);
    }
}
"@
    
    $appPath = Join-Path $serviceDir "src/main/java/com/benefits/$packageName/$simpleName.java"
    if (-not (Test-Path $appPath)) {
        Set-Content -Path $appPath -Value $appContent -Encoding UTF8
    }
    
    # Criar application.yml
    $ymlContent = @"
spring:
  application:
    name: $ServiceName
server:
  port: $Port
management:
  endpoints:
    web:
      exposure:
        include: health,info
  endpoint:
    health:
      show-details: always
"@
    
    $ymlPath = Join-Path $serviceDir "src/main/resources/application.yml"
    if (-not (Test-Path $ymlPath)) {
        Set-Content -Path $ymlPath -Value $ymlContent -Encoding UTF8
    }
    
    # Criar Dockerfile
    $dockerfileContent = @"
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE $Port
ENTRYPOINT ["java", "-jar", "app.jar"]
"@
    
    $dockerfilePath = Join-Path $serviceDir "Dockerfile"
    if (-not (Test-Path $dockerfilePath)) {
        Set-Content -Path $dockerfilePath -Value $dockerfileContent -Encoding UTF8
    }
    
    Write-Host "    ✓ $ServiceName criado" -ForegroundColor Green
}

# Criar todos os serviços
Write-Host "`n[1/2] Criando serviços especializados..." -ForegroundColor Cyan
foreach ($service in $services) {
    Create-Service-Structure -ServiceName $service.Name -Port $service.Port -Description $service.Description
}

# Criar stubs
Write-Host "`n[2/2] Criando stubs para serviços externos..." -ForegroundColor Cyan
foreach ($stub in $stubs) {
    Create-Service-Structure -ServiceName $stub.Name -Port $stub.Port -Description $stub.Description
}

Write-Host "`n✅ Estrutura de serviços criada com sucesso!" -ForegroundColor Green
Write-Host "`n📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "  1. Implementar lógica de negócio em cada serviço" -ForegroundColor White
Write-Host "  2. Adicionar ao docker-compose.yml" -ForegroundColor White
Write-Host "  3. Criar Feign Clients nos BFFs" -ForegroundColor White
Write-Host "  4. Implementar endpoints e controllers" -ForegroundColor White
Write-Host ""
