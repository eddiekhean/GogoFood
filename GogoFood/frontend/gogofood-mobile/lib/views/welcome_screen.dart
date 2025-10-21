import 'package:flutter/material.dart';
import 'package:gogo_food/viewmodels/login_view_model.dart';
import 'package:gogo_food/viewmodels/welcome_view_model.dart';
import 'package:gogo_food/views/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<WelcomeViewModel>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black87,
          image: DecorationImage(
            image: AssetImage('assets/images/login_image.png'),
            opacity: 0.6,
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.15),
                Text(
                  'Welcome to',
                  style: GoogleFonts.sofiaSans(
                    fontSize: 46,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'GoGo Food',
                  style: GoogleFonts.sofiaSans(
                    fontSize: 38,
                    color: const Color(0xFFFF6766),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your favourite foods delivered fast\nat your door.',
                  style: GoogleFonts.sofia(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: size.height * 0.15),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Colors.white54,
                        thickness: 1,
                        endIndent: 20,
                      ),
                    ),
                    Text(
                      'sign in with',
                      style: GoogleFonts.sofia(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Colors.white54,
                        thickness: 1,
                        indent: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _socialButton(
                      'Facebook',
                      'assets/images/facebook.png',
                      vm.signInWithFacebook,
                    ),
                    _socialButton(
                      'Google',
                      'assets/images/google.png',
                      vm.signInWithGoogle,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: _emailOrPhoneButton(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) => LoginViewModel(),
                          child: LoginScreen(),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Do not have an account?',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () => vm.signup(context),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String text, String iconPath, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      icon: Image.asset(iconPath, width: 24, height: 24),
    );
  }

  Widget _emailOrPhoneButton(VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.4),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
      onPressed: onPressed,
      child: const Text(
        'Start with email or phone',
        style: TextStyle(fontSize: 20, color: Colors.black54),
      ),
    );
  }
}
