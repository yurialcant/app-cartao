package com.benefits.identity.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Person Identity Response DTO
 *
 * Combines person information with all associated identity links
 */
public class PersonIdentityResponse {

    private PersonDTO person;
    private List<IdentityLinkDTO> identityLinks;

    public PersonIdentityResponse() {
    }

    public PersonIdentityResponse(PersonDTO person, List<IdentityLinkDTO> identityLinks) {
        this.person = person;
        this.identityLinks = identityLinks;
    }

    public PersonDTO getPerson() {
        return person;
    }

    public void setPerson(PersonDTO person) {
        this.person = person;
    }

    public List<IdentityLinkDTO> getIdentityLinks() {
        return identityLinks;
    }

    public void setIdentityLinks(List<IdentityLinkDTO> identityLinks) {
        this.identityLinks = identityLinks;
    }

    @Override
    public String toString() {
        return "PersonIdentityResponse{" +
                "person=" + person +
                ", identityLinks=" + identityLinks +
                '}';
    }
}