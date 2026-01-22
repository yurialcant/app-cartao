package com.benefits.employerservice.repository;

import com.benefits.employerservice.entity.Employee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EmployeeRepository extends JpaRepository<Employee, String> {
    List<Employee> findByTenantId(String tenantId);
    List<Employee> findByEmployerId(String employerId);
    List<Employee> findByEmployerIdAndStatus(String employerId, Employee.EmployeeStatus status);
    Optional<Employee> findByCpf(String cpf);
    Optional<Employee> findByRegistrationNumber(String registrationNumber);
}
