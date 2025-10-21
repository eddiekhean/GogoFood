import 'package:flutter/material.dart';
import 'package:gogo_food/viewmodels/forgot_password_view_model.dart';
import 'package:gogo_food/viewmodels/otp_view_model.dart';
import 'package:gogo_food/views/otp_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ForgotPasswordScreen();
  }
}

class _ForgotPasswordScreen extends State<ForgotPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForgotPasswordViewModel>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Please enter your phone number or e-mail address to request a password reset',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              focusNode: vm.usernameFocus,
              controller: vm.usernameController,
              decoration: InputDecoration(
                hintText: 'Enter email or phone number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: vm.usernameError != null
                        ? Colors.red
                        : Colors.black54,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: vm.usernameError != null
                        ? Colors.red
                        : Colors.black54,
                  ),
                ),
                errorText: vm.usernameError,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please enter your email address or phone number to change password',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 52),
            ElevatedButton(
              onPressed: vm.isValid
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => OtpViewModel(
                              phoneOrEmail: vm.usernameController.text.trim(),
                            ),
                            child: const OtpScreen(),
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: vm.isValid
                    ? const Color(0xFFE13454)
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
              child: Text(
                'SEND OTP',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
