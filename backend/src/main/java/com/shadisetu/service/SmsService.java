package com.shadisetu.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;

@Service
public class SmsService {

    private static final Logger log = LoggerFactory.getLogger(SmsService.class);
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    @Value("${app.sms.provider:auto}")
    private String smsProvider; // 'fast2sms', 'twilio', '2factor', or 'auto'

    @Value("${app.sms.api-key:}")
    private String smsApiKey;

    // Twilio specific configuration (optional)
    @Value("${app.sms.twilio.account-sid:}")
    private String twilioAccountSid;

    @Value("${app.sms.twilio.auth-token:}")
    private String twilioAuthToken;

    @Value("${app.sms.twilio.from-number:}")
    private String twilioFromNumber;

    /**
     * Dispatch Live SMS OTP to the customer or vendor mobile phone.
     */
    public boolean sendOtpSms(String rawPhone, String otp) {
        String cleanPhone = rawPhone.replaceAll("[^0-9]", "");
        if (cleanPhone.length() > 10) {
            cleanPhone = cleanPhone.substring(cleanPhone.length() - 10);
        }

        String smsMessage = "Your Shaadi Setu verification OTP is: " + otp + ". Valid for 10 minutes. Please do not share this code with anyone.";

        log.info("===============================================================");
        log.info(">>> [LIVE SMS OTP DISPATCH] To: +91 {} | Code: {}", cleanPhone, otp);
        log.info("===============================================================");

        // 1. Try Twilio (User's active credentials)
        if (!twilioAccountSid.isEmpty() && !twilioAuthToken.isEmpty()) {
            boolean twilioSuccess = sendViaTwilio(cleanPhone, smsMessage);
            if (twilioSuccess) return true;
            log.warn(">>> [Twilio SMS] Did not complete. Falling back to Fast2SMS...");
        }

        // 2. Try Fast2SMS (Indian Gateway)
        if (!smsApiKey.isEmpty()) {
            boolean fast2smsSuccess = sendViaFast2Sms(cleanPhone, otp);
            if (fast2smsSuccess) return true;
            log.warn(">>> [Fast2SMS] Did not complete. Falling back to 2Factor if configured...");
        }

        // 3. Try 2Factor
        if ("2factor".equalsIgnoreCase(smsProvider)) {
            return sendVia2Factor(cleanPhone, otp);
        }

        // 4. Fallback / Dev Mode
        log.info(">>> [SMS GATEWAY] No active third-party SMS API key configured in application.yml.");
        log.info(">>> [SMS GATEWAY] OTP {} is ready for verification for +91 {}", otp, cleanPhone);
        return false;
    }

    private boolean sendViaFast2Sms(String phone, String otp) {
        String key = smsApiKey != null ? smsApiKey.trim() : "";
        if (key.isEmpty()) {
            log.warn(">>> [Fast2SMS] API key is empty.");
            return false;
        }

        try {
            log.info(">>> [Fast2SMS] Dispatching live SMS to +91 {} with Code: {}...", phone, otp);
            // 1. Try OTP route
            String jsonPayload = String.format(
                    "{\"route\":\"otp\",\"variables_values\":\"%s\",\"numbers\":\"%s\"}",
                    otp, phone
            );

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://www.fast2sms.com/dev/bulkV2"))
                    .header("authorization", key)
                    .header("Content-Type", "application/json")
                    .timeout(Duration.ofSeconds(10))
                    .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            log.info(">>> [Fast2SMS OTP Route Response] Status: {} | Body: {}", response.statusCode(), response.body());
            if (response.statusCode() == 200 && response.body().contains("\"return\":true")) {
                return true;
            }

            // 2. Try Quick SMS route as fallback
            String quickPayload = String.format(
                    "{\"route\":\"q\",\"message\":\"Your Shaadi Setu verification OTP is %s\",\"language\":\"english\",\"numbers\":\"%s\"}",
                    otp, phone
            );
            HttpRequest quickReq = HttpRequest.newBuilder()
                    .uri(URI.create("https://www.fast2sms.com/dev/bulkV2"))
                    .header("authorization", key)
                    .header("Content-Type", "application/json")
                    .timeout(Duration.ofSeconds(10))
                    .POST(HttpRequest.BodyPublishers.ofString(quickPayload))
                    .build();

            HttpResponse<String> quickRes = httpClient.send(quickReq, HttpResponse.BodyHandlers.ofString());
            log.info(">>> [Fast2SMS Quick Route Response] Status: {} | Body: {}", quickRes.statusCode(), quickRes.body());
            if (quickRes.statusCode() == 200 && quickRes.body().contains("\"return\":true")) {
                return true;
            }

            // 3. Try GET OTP route as third fallback
            String getUrl = "https://www.fast2sms.com/dev/bulkV2?authorization=" + key
                    + "&route=otp&variables_values=" + otp + "&numbers=" + phone + "&flash=0";
            HttpRequest getReq = HttpRequest.newBuilder()
                    .uri(URI.create(getUrl))
                    .timeout(Duration.ofSeconds(10))
                    .GET()
                    .build();
            HttpResponse<String> getRes = httpClient.send(getReq, HttpResponse.BodyHandlers.ofString());
            log.info(">>> [Fast2SMS GET Route Response] Status: {} | Body: {}", getRes.statusCode(), getRes.body());
            return getRes.statusCode() == 200 && getRes.body().contains("\"return\":true");
        } catch (Exception e) {
            log.error(">>> [Fast2SMS] Failed to send SMS: {}", e.getMessage());
            return false;
        }
    }

    private String resolveTwilioFromNumber(String encodedAuth) {
        if (twilioFromNumber != null && !twilioFromNumber.trim().isEmpty()) {
            return twilioFromNumber.trim();
        }
        try {
            String sid = twilioAccountSid != null ? twilioAccountSid.trim() : "";
            String url = "https://api.twilio.com/2010-04-01/Accounts/" + sid + "/IncomingPhoneNumbers.json";
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("Authorization", "Basic " + encodedAuth)
                    .GET()
                    .build();
            HttpResponse<String> resp = httpClient.send(req, HttpResponse.BodyHandlers.ofString());
            log.info(">>> [Twilio Phone Query] Status: {} | Body: {}", resp.statusCode(), resp.body());
            if (resp.statusCode() == 200) {
                java.util.regex.Matcher m = java.util.regex.Pattern.compile("\"phone_number\":\\s*\"([^\"]+)\"").matcher(resp.body());
                if (m.find()) {
                    String num = m.group(1);
                    log.info(">>> [Twilio] Auto-detected Active From Phone Number: {}", num);
                    twilioFromNumber = num;
                    return num;
                }
            }
        } catch (Exception e) {
            log.error(">>> [Twilio] Error resolving phone number: {}", e.getMessage());
        }
        return "";
    }

    private boolean sendViaTwilio(String phone, String message) {
        try {
            String sid = twilioAccountSid != null ? twilioAccountSid.trim() : "";
            String token = twilioAuthToken != null ? twilioAuthToken.trim() : "";
            if (sid.isEmpty() || token.isEmpty()) {
                log.warn(">>> [Twilio] Missing Account SID or Auth Token.");
                return false;
            }

            String auth = sid + ":" + token;
            String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes(StandardCharsets.UTF_8));
            String from = resolveTwilioFromNumber(encodedAuth);

            String toPhone = "+91" + phone;
            log.info(">>> [Twilio SMS] Sending live SMS to {} via Twilio Number: {}...", toPhone, from);

            StringBuilder form = new StringBuilder();
            form.append("To=").append(URLEncoder.encode(toPhone, StandardCharsets.UTF_8));
            if (!from.isEmpty()) {
                form.append("&From=").append(URLEncoder.encode(from, StandardCharsets.UTF_8));
            }
            form.append("&Body=").append(URLEncoder.encode(message, StandardCharsets.UTF_8));

            String twilioUrl = "https://api.twilio.com/2010-04-01/Accounts/" + sid + "/Messages.json";

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(twilioUrl))
                    .header("Authorization", "Basic " + encodedAuth)
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .timeout(Duration.ofSeconds(10))
                    .POST(HttpRequest.BodyPublishers.ofString(form.toString()))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            log.info(">>> [Twilio Response] Status: {} | Body: {}", response.statusCode(), response.body());
            return response.statusCode() >= 200 && response.statusCode() < 300;
        } catch (Exception e) {
            log.error(">>> [Twilio SMS] Failed to send SMS: {}", e.getMessage());
            return false;
        }
    }

    private boolean sendVia2Factor(String phone, String otp) {
        try {
            log.info(">>> [2Factor] Sending live OTP SMS to +91 {}...", phone);
            String url = "https://2factor.in/v1/API/" + smsApiKey + "/SMS/" + phone + "/" + otp + "/ShaadiSetu";
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofSeconds(10))
                    .GET()
                    .build();
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            log.info(">>> [2Factor Response] Status: {} | Body: {}", response.statusCode(), response.body());
            return response.statusCode() == 200;
        } catch (Exception e) {
            log.error(">>> [2Factor] Failed to send SMS: {}", e.getMessage());
            return false;
        }
    }
}
