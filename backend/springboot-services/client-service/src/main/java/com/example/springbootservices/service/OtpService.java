package com.example.springbootservices.service;

import com.example.springbootservices.dto.OtpSenderRequest;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring6.SpringTemplateEngine;

import java.security.SecureRandom;
import java.time.Duration;

@Service
public class OtpService {

    private static final String OTP_PREFIX = "otp:";
    private static final Duration OTP_TTL = Duration.ofMinutes(5);
    private final SecureRandom secureRandom = new SecureRandom();

    private final StringRedisTemplate redisTemplate;
    private final JavaMailSender mailSender;
    private final SpringTemplateEngine templateEngine;

    @Autowired
    public OtpService(StringRedisTemplate redisTemplate,
                      JavaMailSender mailSender,
                      SpringTemplateEngine templateEngine) {
        this.redisTemplate = redisTemplate;
        this.mailSender = mailSender;
        this.templateEngine = templateEngine;
    }

    // --- Gửi OTP qua email (với HTML template) ---
    public void sendOtp(String toEmail) throws MessagingException {
        String otpCode = generateOtpCode();

        // Tạo context Thymeleaf cho template "otp-mail.html"
        Context context = new Context();
        context.setVariable("to", toEmail);
        context.setVariable("otp", otpCode);

        // Render HTML
        String htmlContent = templateEngine.process("otp-mail", context);

        // Gửi mail
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
        helper.setTo(toEmail);
        helper.setSubject("Mã xác thực OTP");
        helper.setText(htmlContent, true);
        mailSender.send(message);

        // Lưu OTP vào Redis với TTL 5 phút
        redisTemplate.opsForValue().set(OTP_PREFIX + toEmail, otpCode, OTP_TTL);
    }

    // --- Xác minh OTP ---
    public boolean verifyOtp(String toEmail, String inputOtp) {
        String key = OTP_PREFIX + toEmail;
        String storedOtp = redisTemplate.opsForValue().get(key);
        if (storedOtp != null && inputOtp.equals(storedOtp)) {
            redisTemplate.delete(key);
            return true;
        }
        return false;
    }

    // --- Sinh mã OTP ngẫu nhiên ---
    private String generateOtpCode() {
        int otp = 100000 + secureRandom.nextInt(900000);
        return String.valueOf(otp);
    }
}
