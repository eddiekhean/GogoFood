import 'package:flutter/material.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isValid = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  final newPasswordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  String? newPasswordError;
  String? confirmPasswordError;

  ResetPasswordViewModel() {
    newPasswordFocus.addListener(() {
      if (!newPasswordFocus.hasFocus) validateNewPassword();
    });

    confirmPasswordFocus.addListener(() {
      if (!confirmPasswordFocus.hasFocus) validateConfirmPassword();
    });

    newPasswordController.addListener(() {
      validateNewPassword();
      _updateValidity();
    });

    confirmPasswordController.addListener(() {
      validateConfirmPassword();
      _updateValidity();
    });
  }

  void _updateValidity() {
    final isPasswordValid =
        newPasswordError == null &&
        newPasswordController.text.trim().isNotEmpty;
    final isConfirmPasswordValid =
        confirmPasswordError == null &&
        confirmPasswordController.text.trim().isNotEmpty;

    isValid = isPasswordValid && isConfirmPasswordValid;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    showConfirmPassword = !showConfirmPassword;
    notifyListeners();
  }

  void validateNewPassword() {
    final newPassword = newPasswordController.text.trim();

    if (newPassword.isEmpty) {
      newPasswordError = 'Password is required';
    } else if (newPassword.length < 6) {
      newPasswordError = 'Password minimum 6 character';
    } else if (!newPassword.contains(RegExp(r'[A-Z]'))) {
      newPasswordError = 'Contains at least one uppercase letter';
    } else if (!newPassword.contains(RegExp(r'[a-z]'))) {
      newPasswordError = 'Contains at least one lowercase letter';
    } else if (!newPassword.contains(RegExp(r'[0-9]'))) {
      newPasswordError = 'Contains at least one digit (0-9)';
    } else if (!newPassword.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
      newPasswordError = 'Contains at least one special character';
    } else {
      newPasswordError = null;
    }
    notifyListeners();
  }

  void validateConfirmPassword() {
    final confirmPassword = confirmPasswordController.text.trim();

    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'Confirm password is required';
    } else if (confirmPassword != newPasswordController.text.trim()) {
      confirmPasswordError = 'Password confirmation does not match';
    } else {
      confirmPasswordError = null;
    }
    notifyListeners();
  }
}
