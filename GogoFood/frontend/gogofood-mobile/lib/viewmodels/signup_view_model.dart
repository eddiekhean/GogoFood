import 'package:flutter/material.dart';

class SignupViewModel extends ChangeNotifier {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isValid = false;

  final fullNameFocus = FocusNode();
  final emailFocus = FocusNode();
  final phoneFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();
  final usernameFocus = FocusNode();

  String? fullNameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? phoneError;
  String? usernameError;

  SignupViewModel() {
    fullNameFocus.addListener(() {
      if (!fullNameFocus.hasFocus) validateFullName();
    });

    emailFocus.addListener(() {
      if (!emailFocus.hasFocus) validateEmail();
    });

    phoneFocus.addListener(() {
      if (!phoneFocus.hasFocus) validatePhone();
    });

    usernameFocus.addListener(() {
      if (!usernameFocus.hasFocus) validateUsername();
    });

    passwordFocus.addListener(() {
      if (!passwordFocus.hasFocus) validatePassword();
    });

    confirmPasswordFocus.addListener(() {
      if (!confirmPasswordFocus.hasFocus) validateConfirmPassword();
    });

    fullNameController.addListener(() {
      validateFullName();
      _validateAll();
    });

    emailController.addListener(() {
      validateEmail();
      _validateAll();
    });

    usernameController.addListener(() {
      validateUsername();
      _validateAll();
    });

    phoneController.addListener(() {
      validatePhone();
      _validateAll();
    });

    passwordController.addListener(() {
      validatePassword();
      _validateAll();
    });

    confirmPasswordController.addListener(() {
      validateConfirmPassword();
      _validateAll();
    });
  }

  void togglePasswordVisibility() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    showConfirmPassword = !showConfirmPassword;
    notifyListeners();
  }

  void signup() {}

  void signInWithGoogle() {}

  void signInWithFacebook() {}

  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateAll() {
    validateFullName();
    validateEmail();
    validatePhone();
    validateUsername();
    validatePassword();
    validateConfirmPassword();

    isValid =
        fullNameError == null &&
        emailError == null &&
        phoneError == null &&
        usernameError == null &&
        passwordError == null &&
        confirmPasswordError == null;

    notifyListeners();
  }

  void validateFullName() {
    final name = fullNameController.text.trim();
    if (name.isEmpty) {
      fullNameError = 'Full name is required';
    } else if (name.length > 100) {
      fullNameError = 'Full name maximum 100 characters';
    } else {
      fullNameError = null;
    }
    notifyListeners();
  }

  void validateEmail() {
    final email = emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isEmpty) {
      emailError = 'Email is required';
    } else if (!emailRegex.hasMatch(email)) {
      emailError = 'Invalid email address';
    } else {
      emailError = null;
    }
    notifyListeners();
  }

  void validatePhone() {
    final phone = phoneController.text.trim();
    final phoneRegex = RegExp(r'^\d{9,11}$');
    if (phone.isEmpty) {
      phoneError = "Phone is required";
    } else if (!phoneRegex.hasMatch(phone)) {
      phoneError = 'Invalid phone number';
    } else {
      phoneError = null;
    }
    notifyListeners();
  }

  void validateUsername() {
    final username = usernameController.text.trim();
    if (username.isEmpty) {
      usernameError = 'Username is required';
    } else if (username.length < 4 || username.length > 50) {
      usernameError = 'Username must be between 4 and 50 characters';
    } else {
      usernameError = null;
    }
    notifyListeners();
  }

  void validatePassword() {
    final password = passwordController.text;

    if (password.isEmpty) {
      passwordError = 'Password is required';
    } else if (password.length < 6) {
      passwordError = 'Password minimum 6 character';
    } else if (!password.contains(RegExp(r'[A-Z]'))) {
      passwordError = 'Contains at least one uppercase letter';
    } else if (!password.contains(RegExp(r'[a-z]'))) {
      passwordError = 'Contains at least one lowercase letter';
    } else if (!password.contains(RegExp(r'[0-9]'))) {
      passwordError = 'Contains at least one digit (0-9)';
    } else if (!password.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
      passwordError = 'Contains at least one special character';
    } else {
      passwordError = null;
    }
    notifyListeners();
  }

  void validateConfirmPassword() {
    final confirmPassword = confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'Confirm password is required';
    } else if (confirmPassword != passwordController.text) {
      confirmPasswordError = 'Password confirmation dose not match';
    } else {
      confirmPasswordError = null;
    }
    notifyListeners();
  }
}
