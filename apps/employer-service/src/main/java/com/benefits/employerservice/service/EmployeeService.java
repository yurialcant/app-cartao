package com.benefits.employerservice.service;

import com.benefits.employerservice.entity.Employee;
import com.benefits.employerservice.repository.EmployeeRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class EmployeeService {
    
    private static final Logger log = LoggerFactory.getLogger(EmployeeService.class);
    private final EmployeeRepository employeeRepository;
    
    @Transactional
    public Employee createEmployee(Employee employee) {
        log.info("🔵 [EMPLOYEE] Criando employee: {} - Employer: {}", employee.getName(), employee.getEmployerId());
        return employeeRepository.save(employee);
    }
    
    public List<Employee> getEmployeesByEmployer(String employerId) {
        log.debug("🔵 [EMPLOYEE] Buscando employees para employer: {}", employerId);
        return employeeRepository.findByEmployerId(employerId);
    }
    
    public List<Employee> getActiveEmployeesByEmployer(String employerId) {
        log.debug("🔵 [EMPLOYEE] Buscando employees ativos para employer: {}", employerId);
        return employeeRepository.findByEmployerIdAndStatus(employerId, Employee.EmployeeStatus.ACTIVE);
    }
    
    public Employee getEmployeeById(String id) {
        log.debug("🔵 [EMPLOYEE] Buscando employee por ID: {}", id);
        return employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found: " + id));
    }
    
    @Transactional
    public Employee updateEmployeeStatus(String id, Employee.EmployeeStatus status) {
        log.info("🔵 [EMPLOYEE] Atualizando status do employee: {} para {}", id, status);
        Employee employee = employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found: " + id));
        employee.setStatus(status);
        return employeeRepository.save(employee);
    }
    
    @Transactional
    public void transferEmployee(String employeeId, String newEmployerId, String newCostCenterId) {
        log.info("🔵 [EMPLOYEE] Transferindo employee: {} para employer: {}", employeeId, newEmployerId);
        Employee employee = employeeRepository.findById(employeeId)
                .orElseThrow(() -> new RuntimeException("Employee not found: " + employeeId));
        employee.setEmployerId(newEmployerId);
        employee.setCostCenterId(newCostCenterId);
        employee.setStatus(Employee.EmployeeStatus.TRANSFERRED);
        employeeRepository.save(employee);
    }
}
