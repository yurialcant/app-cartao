package com.benefits.support.service;

import com.benefits.support.entity.SupportTicket;
import com.benefits.support.repository.SupportTicketRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import java.util.UUID;

@Service
public class SupportService {

    private static final Logger log = LoggerFactory.getLogger(SupportService.class);

    private final SupportTicketRepository ticketRepository;

    public SupportService(SupportTicketRepository ticketRepository) {
        this.ticketRepository = ticketRepository;
    }

    // Create support ticket
    public Mono<SupportTicket> createTicket(UUID tenantId, String ticketNumber, UUID personId,
                                          String category, String priority, String title, String description) {
        log.info("[Support] Creating ticket: {} for person: {}", ticketNumber, personId);

        return ticketRepository.existsByTicketNumber(ticketNumber)
            .flatMap(exists -> {
                if (exists) {
                    return Mono.error(new IllegalArgumentException("Ticket number already exists"));
                }

                SupportTicket ticket = new SupportTicket(tenantId, ticketNumber, personId, category, priority, title, description);
                return ticketRepository.save(ticket);
            });
    }

    // Get ticket by ID
    public Mono<SupportTicket> getTicket(UUID tenantId, UUID ticketId) {
        log.info("[Support] Getting ticket: {}", ticketId);

        return ticketRepository.findById(ticketId)
            .filter(ticket -> tenantId.equals(ticket.getTenantId()));
    }

    // Get ticket by ticket number
    public Mono<SupportTicket> getTicketByNumber(UUID tenantId, String ticketNumber) {
        log.info("[Support] Getting ticket by number: {}", ticketNumber);

        return ticketRepository.findByTenantIdAndTicketNumber(tenantId, ticketNumber);
    }

    // List tickets for tenant
    public Flux<SupportTicket> listTickets(UUID tenantId) {
        log.info("[Support] Listing tickets for tenant: {}", tenantId);

        return ticketRepository.findByTenantId(tenantId);
    }

    // Update ticket status
    public Mono<SupportTicket> updateTicketStatus(UUID tenantId, UUID ticketId, String status) {
        log.info("[Support] Updating ticket status: {} for ticket: {}", status, ticketId);

        return ticketRepository.findById(ticketId)
            .filter(ticket -> tenantId.equals(ticket.getTenantId()))
            .flatMap(ticket -> {
                ticket.setStatus(status);
                return ticketRepository.save(ticket);
            });
    }

    // Update ticket
    public Mono<SupportTicket> updateTicket(UUID tenantId, UUID ticketId, SupportTicket updates) {
        log.info("[Support] Updating ticket: {}", ticketId);

        return ticketRepository.findById(ticketId)
            .filter(ticket -> tenantId.equals(ticket.getTenantId()))
            .flatMap(ticket -> {
                if (updates.getTitle() != null) ticket.setTitle(updates.getTitle());
                if (updates.getDescription() != null) ticket.setDescription(updates.getDescription());
                if (updates.getCategory() != null) ticket.setCategory(updates.getCategory());
                if (updates.getPriority() != null) ticket.setPriority(updates.getPriority());
                if (updates.getAssignedTo() != null) ticket.setAssignedTo(updates.getAssignedTo());
                if (updates.getResolution() != null) ticket.setResolution(updates.getResolution());

                return ticketRepository.save(ticket);
            });
    }

    // Get ticket statistics
    public Mono<TicketStats> getTicketStats(UUID tenantId) {
        log.info("[Support] Getting ticket stats for tenant: {}", tenantId);

        return ticketRepository.findByTenantId(tenantId)
            .collectList()
            .map(tickets -> {
                long total = tickets.size();
                long open = tickets.stream().filter(SupportTicket::isOpen).count();
                long inProgress = tickets.stream().filter(SupportTicket::isInProgress).count();
                long resolved = tickets.stream().filter(SupportTicket::isResolved).count();
                long closed = tickets.stream().filter(SupportTicket::isClosed).count();
                long highPriority = tickets.stream().filter(SupportTicket::isHighPriority).count();

                return new TicketStats(total, open, inProgress, resolved, closed, highPriority);
            });
    }

    // DTO for statistics
    public static class TicketStats {
        private final long total;
        private final long open;
        private final long inProgress;
        private final long resolved;
        private final long closed;
        private final long highPriority;

        public TicketStats(long total, long open, long inProgress, long resolved, long closed, long highPriority) {
            this.total = total;
            this.open = open;
            this.inProgress = inProgress;
            this.resolved = resolved;
            this.closed = closed;
            this.highPriority = highPriority;
        }

        public long getTotal() { return total; }
        public long getOpen() { return open; }
        public long getInProgress() { return inProgress; }
        public long getResolved() { return resolved; }
        public long getClosed() { return closed; }
        public long getHighPriority() { return highPriority; }
    }
}