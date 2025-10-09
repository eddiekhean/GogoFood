package com.example.springbootservices.controller;

import com.example.springbootservices.dto.OtpSenderRequest;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring6.SpringTemplateEngine;

@RestController
@RequestMapping("/api/email")
public class MailController {
    @Autowired
    private JavaMailSender mailSender;
    @Autowired
    private SpringTemplateEngine templateEngine;

    @PostMapping("/send")
    public ResponseEntity<String> sendEmail(@RequestBody OtpSenderRequest request) throws MessagingException {
        try {
            Context context = new Context();
            context.setVariable("to", request.getTo());     // Gửi tên người nhận
            context.setVariable("otp", request.getOtp());   // Gửi mã OTP

            String htmlContent = templateEngine.process("otp-mail", context);

            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setTo(request.getTo());
            helper.setSubject("Mã xác thực OTP");
            helper.setText(htmlContent, true);

            mailSender.send(message);
            return ResponseEntity.ok("Đã gửi mail thành công");

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Lỗi gửi mail: " + e.getMessage());
        }
    }
}