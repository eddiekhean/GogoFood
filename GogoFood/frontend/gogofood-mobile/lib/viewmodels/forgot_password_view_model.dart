import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final usernameController = TextEditingController();
  final usernameFocus = FocusNode();
  String? usernameError;
  bool isValid = false;

  ForgotPasswordViewModel() {
    usernameFocus.addListener(() {
      if (!usernameFocus.hasFocus) validateUsername();
    });

    usernameController.addListener(() {
      validateUsername();
    });
  }

  void validateUsername() {
    final username = usernameController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(r'^\d{9,11}$');
    if (username.isEmpty) {
      usernameError = 'Email or phone number is required';
    } else if (!emailRegex.hasMatch(username) &&
        !phoneRegex.hasMatch(username)) {
      usernameError = 'Please enter a valid email or phone number';
    } else {
      usernameError = null;
    }

    isValid = usernameError == null;
    notifyListeners();
  }
}
