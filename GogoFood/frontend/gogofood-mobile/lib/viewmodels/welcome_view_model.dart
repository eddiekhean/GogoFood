import 'package:flutter/material.dart';
import 'package:gogo_food/viewmodels/signup_view_model.dart';
import 'package:gogo_food/views/signup_screen.dart';
import 'package:provider/provider.dart';

class WelcomeViewModel extends ChangeNotifier {
  void signInWithFacebook() {}

  void signInWithGoogle() {}
  void signup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => SignupViewModel(),
          child: const SignupScreen(),
        ),
      ),
    );
  }
}
