import 'package:flutter/material.dart';
import 'package:gogo_food/viewmodels/login_view_model.dart';
import 'package:gogo_food/viewmodels/reset_password_view_model.dart';
import 'package:gogo_food/views/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() {
    return _ResetPasswordScreen();
  }
}

class _ResetPasswordScreen extends State<ResetPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ResetPasswordViewModel>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Reset password',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTextField(
              focusNode: vm.newPasswordFocus,
              hintText: 'Enter password',
              label: 'Password',
              controller: vm.newPasswordController,
              obscureText: !vm.showPassword,
              toggleVisibility: vm.togglePasswordVisibility,
              errorText: vm.newPasswordError,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              focusNode: vm.confirmPasswordFocus,
              hintText: 'Enter confirm password',
              label: 'Confirm password',
              controller: vm.confirmPasswordController,
              obscureText: !vm.showConfirmPassword,
              toggleVisibility: vm.toggleConfirmPasswordVisibility,
              errorText: vm.confirmPasswordError,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: vm.isValid
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => LoginViewModel(),
                            child: const LoginScreen(),
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: vm.isValid ? Color(0xFFE13454) : Colors.grey,
                padding: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(24),
                ),
              ),
              child: Text(
                'Reset password',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required FocusNode focusNode,
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? errorText,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 8),
        TextField(
          focusNode: focusNode,
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: hintText,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.grey,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.grey,
              ),
            ),
            errorText: errorText,
            suffixIcon: IconButton(
              onPressed: toggleVisibility,
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
            ),
          ),
        ),
      ],
    );
  }
}
