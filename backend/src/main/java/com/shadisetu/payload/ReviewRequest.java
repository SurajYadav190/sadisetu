package com.shadisetu.payload;

public class ReviewRequest {
    private Long bookingId;
    private Integer rating;
    private String comment;
    private String mediaUrlsJson;

    public ReviewRequest() {}

    public Long getBookingId() { return bookingId; }
    public void setBookingId(Long bookingId) { this.bookingId = bookingId; }

    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public String getMediaUrlsJson() { return mediaUrlsJson; }
    public void setMediaUrlsJson(String mediaUrlsJson) { this.mediaUrlsJson = mediaUrlsJson; }
}
