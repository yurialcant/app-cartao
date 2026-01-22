#!/usr/bin/env powershell
# Complete WebFlux + R2DBC setup for all 4 remaining BFFs

param(
    [string]$Action = "setup"
)

$bffs = @(
    @{
        name = "employer-bff"
        pkg = "employerbff"
        appClass = "EmployerBffApplication"
        entity = "Employer"
        response = "EmployerResponse"
        fields = @("id", "name", "contactEmail", "phone", "active", "createdAt", "updatedAt")
    },
    @{
        name = "merchant-bff"
        pkg = "merchantbff"
        appClass = "MerchantBffApplication"
        entity = "Merchant"
        response = "MerchantResponse"
        fields = @("id", "name", "merchantType", "active", "createdAt", "updatedAt")
    },
    @{
        name = "user-bff"
        pkg = "userbff"
        appClass = "UserBffApplication"
        entity = "User"
        response = "UserResponse"
        fields = @("id", "username", "email", "fullName", "active", "createdAt", "updatedAt")
    },
    @{
        name = "merchant-portal-bff"
        pkg = "merchantportalbff"
        appClass = "MerchantPortalBffApplication"
        entity = "MerchantPortalUser"
        response = "MerchantPortalUserResponse"
        fields = @("id", "username", "email", "merchantId", "role", "active", "createdAt", "updatedAt")
    }
)

$basePath = "c:\Users\gesch\Documents\projeto-lucas\services"

function Create-Entity {
    param($bff)
    
    $entityPath = "$basePath\$($bff.name)\src\main\java\com\benefits\$($bff.pkg)\entity\$($bff.entity).java"
    mkdir -Force (Split-Path $entityPath) -ErrorAction SilentlyContinue | Out-Null
    
    $code = @"
package com.benefits.$($bff.pkg).entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;

@Table("$(($bff.entity.ToLower() + 's'))")
public class $($bff.entity) {
    
    @Id
    private String id;
    
"@
    
    # Add fields
    foreach ($field in $bff.fields | Where-Object { $_ -ne "id" }) {
        if ($field -eq "createdAt" -or $field -eq "updatedAt") {
            $code += "    @Column(`"$(($field -creplace '([a-z])([A-Z])', '$1_$2').ToLower())`")`n"
            $code += "    private LocalDateTime $field;`n`n"
        } elseif ($field -eq "active") {
            $code += "    @Column(`"active`")`n"
            $code += "    private Boolean active;`n`n"
        } else {
            $colName = $field -creplace '([a-z])([A-Z])', '$1_$2'
            $code += "    @Column(`"$($colName.ToLower())`")`n"
            $code += "    private String $field;`n`n"
        }
    }
    
    # Constructor
    $code += "    public $($bff.entity)() {}`n`n"
    
    # Full constructor
    $params = @("String id")
    foreach ($field in $bff.fields | Where-Object { $_ -ne "id" }) {
        if ($field -eq "createdAt" -or $field -eq "updatedAt") {
            $params += "LocalDateTime $field"
        } elseif ($field -eq "active") {
            $params += "Boolean $field"
        } else {
            $params += "String $field"
        }
    }
    
    $code += "    public $($bff.entity)($($params -join ', ')) {`n"
    $code += "        this.id = id;`n"
    foreach ($field in $bff.fields | Where-Object { $_ -ne "id" }) {
        $code += "        this.$field = $field;`n"
    }
    $code += "    }`n`n"
    
    # Builder
    $code += "    public static $($bff.entity)Builder builder() {`n"
    $code += "        return new $($bff.entity)Builder();`n"
    $code += "    }`n`n"
    $code += "    public static class $($bff.entity)Builder {`n"
    foreach ($field in $bff.fields) {
        if ($field -eq "createdAt" -or $field -eq "updatedAt") {
            $code += "        private LocalDateTime $field;`n"
        } elseif ($field -eq "active") {
            $code += "        private Boolean $field;`n"
        } else {
            $code += "        private String $field;`n"
        }
    }
    $code += "`n"
    foreach ($field in $bff.fields) {
        $code += "        public $($bff.entity)Builder $field($field) { this.$field = $field; return this; }`n"
    }
    $code += "`n        public $($bff.entity) build() {`n"
    $code += "            return new $($bff.entity)($($bff.fields -join ', '));`n"
    $code += "        }`n    }`n`n"
    
    # Getters and Setters
    foreach ($field in $bff.fields) {
        $getter = $field[0].ToString().ToUpper() + $field.Substring(1)
        if ($field -eq "createdAt" -or $field -eq "updatedAt") {
            $type = "LocalDateTime"
        } elseif ($field -eq "active") {
            $type = "Boolean"
        } else {
            $type = "String"
        }
        $code += "    public $type get$getter() { return $field; }`n"
    }
    $code += "`n"
    foreach ($field in $bff.fields) {
        $setter = $field[0].ToString().ToUpper() + $field.Substring(1)
        if ($field -eq "createdAt" -or $field -eq "updatedAt") {
            $type = "LocalDateTime"
        } elseif ($field -eq "active") {
            $type = "Boolean"
        } else {
            $type = "String"
        }
        $code += "    public void set$setter($type $field) { this.$field = $field; }`n"
    }
    
    $code += "}`n"
    
    $code | Out-File $entityPath -Encoding UTF8 -Force
    return $entityPath
}

function Create-Repository {
    param($bff)
    
    $repoPath = "$basePath\$($bff.name)\src\main\java\com\benefits\$($bff.pkg)\repository\$($bff.entity)Repository.java"
    mkdir -Force (Split-Path $repoPath) -ErrorAction SilentlyContinue | Out-Null
    
    $code = @"
package com.benefits.$($bff.pkg).repository;

import com.benefits.$($bff.pkg).entity.$($bff.entity);
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Repository
public interface $($bff.entity)Repository extends R2dbcRepository<$($bff.entity), String> {
    
    Flux<$($bff.entity)> findByActiveTrue();
    
    Mono<$($bff.entity)> findByNameIgnoreCase(String name);
    
    @Query("SELECT * FROM $(($bff.entity.ToLower() + 's')) ORDER BY created_at DESC")
    Flux<$($bff.entity)> findAllOrderByCreatedAtDesc();
    
    Mono<Long> countByActiveTrue();
}
"@
    
    $code | Out-File $repoPath -Encoding UTF8 -Force
    return $repoPath
}

# Execute
if ($Action -eq "setup") {
    foreach ($bff in $bffs) {
        Write-Host "Setting up $($bff.name)..."
        Create-Entity $bff | Out-Null
        Write-Host "  ✅ $($bff.entity) entity created"
        Create-Repository $bff | Out-Null
        Write-Host "  ✅ $($bff.entity)Repository created"
    }
    Write-Host "`n✅ All entities and repositories created!"
}
