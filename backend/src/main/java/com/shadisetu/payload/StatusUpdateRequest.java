package com.shadisetu.payload;

public class StatusUpdateRequest {
    private String status; // ACCEPTED, REJECTED, IN_PROGRESS, COMPLETED, CANCELLED, ESCROW_RELEASED, REFUNDED
    private String reasonOrNotes;

    public StatusUpdateRequest() {}

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getReasonOrNotes() { return reasonOrNotes; }
    public void setReasonOrNotes(String reasonOrNotes) { this.reasonOrNotes = reasonOrNotes; }
}
