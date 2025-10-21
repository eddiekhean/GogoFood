import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gogo_food/viewmodels/reset_password_view_model.dart';
import 'package:gogo_food/views/reset_password_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OtpViewModel extends ChangeNotifier {
  final List<TextEditingController> controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  final String phoneOrEmail;
  bool isValid = false;
  int countdown = 180;
  Timer? _timer;
  String? otpError;

  BuildContext? _context;

  OtpViewModel({required this.phoneOrEmail}) {
    for (var i = 0; i < controllers.length; i++) {
      controllers[i].addListener(validateOtp);
    }
    _startTimer();
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  void validateOtp() {
    isValid = controllers.every((c) => c.text.trim().isNotEmpty);

    if (isValid && _context != null) {
      verifyOtp(_context!);
    }

    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    countdown = 180;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        timer.cancel();
        resend(auto: true);
      } else {
        countdown--;
        notifyListeners();
      }
    });
  }

  void resend({bool auto = false}) {
    countdown = 180;
    _startTimer();

    if (!auto) {
      ScaffoldMessenger.of(
        _context!,
      ).showSnackBar(const SnackBar(content: Text('OTP has been resent')));
    }
    // trigger resend API
    notifyListeners();
  }

  String getOtpCode() {
    return controllers.map((c) => c.text).join();
  }

  Future<void> verifyOtp(BuildContext context) async {
    final code = getOtpCode();

    if (code == '1234') {
      otpError = null;
      notifyListeners();
      _showSuccessDialog(context);
    } else {
      otpError = 'Wrong code';
      notifyListeners();
    }
  }

  void dispose() {
    _timer?.cancel();
    for (var c in controllers) {
      c.dispose();
    }

    for (var f in focusNodes) {
      f.dispose();
    }

    super.dispose();
  }

  void fillOtp(String code) {
    for (int i = 0; i < controllers.length && i < code.length; i++) {
      controllers[i].text = code[i];
    }
    validateOtp();
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFE13454), size: 48),
            const SizedBox(height: 16),
            Text(
              'Registered Successfully',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              phoneOrEmail,
              style: GoogleFonts.inter(
                fontSize: 18,
                color: Color(0xFFFF6B00),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your phone number has been successfully registered',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => ResetPasswordViewModel(),
                        child: const ResetPasswordScreen(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE13454),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Continue on home',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
