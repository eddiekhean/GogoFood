import 'package:flutter/material.dart';
import 'package:gogo_food/viewmodels/forgot_password_view_model.dart';
import 'package:gogo_food/viewmodels/login_view_model.dart';
import 'package:gogo_food/views/forgot_password_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Log In',
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTextField(
              focusNode: vm.usernameFocus,
              label: 'Username or phone or email',
              hintText: 'Enter username or phone or email',
              controller: vm.usernameController,
              errorText: vm.usernameError,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              focusNode: vm.passwordFocus,
              label: 'Password',
              hintText: 'Enter password',
              errorText: vm.passwordError,
              controller: vm.passwordController,
              isPassword: true,
              toogleVisibility: vm.togglePasswordVisibility,
              obscureText: !vm.showPassword,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => ForgotPasswordViewModel(),
                        child: ForgotPasswordScreen(),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Forgot a password?',
                  style: TextStyle(color: Colors.redAccent, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: vm.isValid ? vm.login : null,
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
                child: const Text(
                  'SIGN IN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(child: Divider(endIndent: 10)),
                Text('Sign up with', style: TextStyle(fontSize: 18)),
                Expanded(child: Divider(indent: 10)),
              ],
            ),
            const SizedBox(height: 40),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialButton(
                  'Continue with Facebook',
                  'assets/images/facebook.png',
                  vm.signInWithFacebook,
                  const Color.fromRGBO(63, 86, 147, 1),
                ),
                _socialButton(
                  'Continue with Google',
                  'assets/images/google.png',
                  vm.signInWithGoogle,
                  Color.fromRGBO(83, 132, 237, 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required FocusNode focusNode,
    required String label,
    required String hintText,
    required TextEditingController controller,
    String? errorText,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? toogleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 4),
        TextField(
          focusNode: focusNode,
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.black54,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.black54,
              ),
            ),
            errorText: errorText,
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: toogleVisibility,
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _socialButton(
    String text,
    String iconPath,
    VoidCallback onPressed,
    Color backgroundColor,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Image.asset(iconPath, width: 24, height: 24),
      label: Text(text, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(24),
        ),
      ),
    );
  }
}
