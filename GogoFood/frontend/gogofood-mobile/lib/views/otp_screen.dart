import 'package:flutter/material.dart';
import 'package:gogo_food/viewmodels/otp_view_model.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _OtpScreen();
  }
}

class _OtpScreen extends State<OtpScreen> with CodeAutoFill {
  late OtpViewModel vm;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    vm = context.read<OtpViewModel>();
    vm.setContext(context);
  }

  @override
  void initState() {
    super.initState();
    listenForCode();
  }

  @override
  void codeUpdated() {
    final vm = context.read<OtpViewModel>();
    if (code != null && code!.length == 4) {
      vm.fillOtp(code!);
    }
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<OtpViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Enter the confirm code',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: vm.controllers[index],
                    focusNode: vm.focusNodes[index],
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      vm.validateOtp();
                      if (value.isNotEmpty && index < 3) {
                        vm.focusNodes[index + 1].requestFocus();
                      }
                      if (value.isEmpty && index > 0) {
                        vm.focusNodes[index - 1].requestFocus();
                      }
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: vm.otpError != null ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (vm.otpError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  vm.otpError!,
                  style: GoogleFonts.inter(
                    color: Colors.redAccent,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  const TextSpan(text: 'Verification code has been sent to '),
                  TextSpan(
                    text: vm.phoneOrEmail,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            vm.countdown > 0
                ? Text(
                    'Resend (${vm.countdown})',
                    style: GoogleFonts.inter(color: Colors.redAccent),
                  )
                : TextButton(
                    onPressed: () => vm.resend,
                    child: Text(
                      'Resend',
                      style: GoogleFonts.inter(color: Colors.redAccent),
                    ),
                  ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: vm.isValid ? () => vm.verifyOtp(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: vm.isValid
                    ? const Color(0xFFE13454)
                    : Colors.grey,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'Continue',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
