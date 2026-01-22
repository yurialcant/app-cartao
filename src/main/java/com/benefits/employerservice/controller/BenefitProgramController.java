package com.benefits.employerservice.controller;

import com.benefits.employerservice.entity.BenefitProgram;
import com.benefits.employerservice.service.BenefitProgramService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/programs")
@RequiredArgsConstructor
public class BenefitProgramController {
    
    private static final Logger log = LoggerFactory.getLogger(BenefitProgramController.class);
    private final BenefitProgramService programService;
    
    @PostMapping
    public ResponseEntity<BenefitProgram> createProgram(@RequestBody BenefitProgram program) {
        log.info("🔵 [PROGRAM] POST /api/programs");
        return ResponseEntity.ok(programService.createProgram(program));
    }
    
    @GetMapping("/employer/{employerId}")
    public ResponseEntity<List<BenefitProgram>> getProgramsByEmployer(@PathVariable String employerId) {
        log.info("🔵 [PROGRAM] GET /api/programs/employer/{}", employerId);
        return ResponseEntity.ok(programService.getProgramsByEmployer(employerId));
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<BenefitProgram> updateProgram(@PathVariable String id, @RequestBody BenefitProgram program) {
        log.info("🔵 [PROGRAM] PUT /api/programs/{}", id);
        return ResponseEntity.ok(programService.updateProgram(id, program));
    }
}
