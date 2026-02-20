#!/usr/bin/env powershell
# Migration strategy: benefits-core from JPA to R2DBC

# STEP 1: Backup original
Copy-Item "c:\Users\gesch\Documents\projeto-lucas\services\benefits-core\pom.xml" `
    "c:\Users\gesch\Documents\projeto-lucas\services\benefits-core\pom.xml.jpa.backup" -Force

# STEP 2: Read and modify pom.xml
$pomPath = "c:\Users\gesch\Documents\projeto-lucas\services\benefits-core\pom.xml"
$pom = Get-Content $pomPath -Raw

# Replace JPA with R2DBC
$pom = $pom -replace 'spring-boot-starter-data-jpa', 'spring-boot-starter-data-r2dbc'
$pom = $pom -replace 'spring-boot-starter-jdbc', ''

# Ensure R2DBC PostgreSQL is there
if ($pom -notmatch 'r2dbc-postgresql') {
    $pom = $pom -replace '(</dependencies>)', `
        '<dependency><groupId>org.postgresql</groupId><artifactId>r2dbc-postgresql</artifactId><scope>runtime</scope></dependency>$1'
}

# Add WebFlux if missing
if ($pom -notmatch 'spring-boot-starter-webflux') {
    $pom = $pom -replace '(<dependency>.*?spring-boot-starter-security.*?</dependency>)', `
        '<dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-webflux</artifactId></dependency>$1'
}

$pom | Out-File $pomPath -Encoding UTF8 -Force
Write-Host "✅ benefits-core pom.xml updated: JPA → R2DBC"

# STEP 3: Update application.yml to R2DBC
$ymlPath = "c:\Users\gesch\Documents\projeto-lucas\services\benefits-core\src\main\resources\application.yml"
$yml = @"
spring:
  application:
    name: benefits-core
  r2dbc:
    url: r2dbc:postgresql://benefits-postgres:5432/benefits
    username: benefits
    password: benefits123
    pool:
      initial-size: 20
      max-size: 50
      max-idle-time: 30m
  jpa:
    database-platform: org.hibernate.dialect.PostgreSQLDialect
    hibernate:
      ddl-auto: validate

server:
  port: 8091

logging:
  level:
    root: INFO
    com.benefits: DEBUG
"@

mkdir -Force (Split-Path $ymlPath) -ErrorAction SilentlyContinue | Out-Null
$yml | Out-File $ymlPath -Encoding UTF8 -Force
Write-Host "✅ benefits-core application.yml updated to R2DBC config"

# STEP 4: Repeat for tenant-service
Copy-Item "c:\Users\gesch\Documents\projeto-lucas\services\tenant-service\pom.xml" `
    "c:\Users\gesch\Documents\projeto-lucas\services\tenant-service\pom.xml.jpa.backup" -Force

$pomPath = "c:\Users\gesch\Documents\projeto-lucas\services\tenant-service\pom.xml"
$pom = Get-Content $pomPath -Raw
$pom = $pom -replace 'spring-boot-starter-data-jpa', 'spring-boot-starter-data-r2dbc'
$pom = $pom -replace 'spring-boot-starter-jdbc', ''

if ($pom -notmatch 'r2dbc-postgresql') {
    $pom = $pom -replace '(</dependencies>)', `
        '<dependency><groupId>org.postgresql</groupId><artifactId>r2dbc-postgresql</artifactId><scope>runtime</scope></dependency>$1'
}

$pom | Out-File $pomPath -Encoding UTF8 -Force
Write-Host "✅ tenant-service pom.xml updated: JPA → R2DBC"

$ymlPath = "c:\Users\gesch\Documents\projeto-lucas\services\tenant-service\src\main\resources\application.yml"
$yml | Out-File $ymlPath -Encoding UTF8 -Force
Write-Host "✅ tenant-service application.yml updated to R2DBC config"

Write-Host "`n✅ Domain services pom.xml + application.yml updated for R2DBC!`n"
Write-Host "⚠️  NOTE: Entity annotations still need manual conversion (JPA → R2DBC format)`n"
Write-Host "   Next: Update all @Entity → @Table, @Id imports, @Column imports in entity files"
