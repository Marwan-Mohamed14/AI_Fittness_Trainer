import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Authcontroller extends GetxController {
  // TextEditingControllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // For showing loading spinner
  RxBool isLoading = false.obs;

  final supabase = Supabase.instance.client;

  // ---------------------------
  // SIGN UP
  // ---------------------------
  Future<void> signUp() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validation
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }

    // Email format validation
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Error",
        "Please enter a valid email address",
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }

    // Password length validation
    if (password.length < 6) {
      Get.snackbar(
        "Error",
        "Password must be at least 6 characters",
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {"username": username},
      );

      isLoading.value = false;

      // Check if signup was successful
      if (response.user != null && response.session != null) {
        // Clear the form first
        usernameController.clear();
        emailController.clear();
        passwordController.clear();

        // Show success message
        Get.snackbar(
          "Success",
          "Account created successfully!",
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

        // Navigate after a short delay to ensure snackbar is shown
        Future.delayed(Duration(milliseconds: 500), () {
          Get.offAllNamed('/age-screen');
        });
      } else {
      
        // Signup failed
        Get.snackbar(
          "Error",
          "Signup failed. Please try again.",
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } on AuthException catch (e) {
      isLoading.value = false;

      // Handle Supabase auth errors
      String errorMessage = "Signup failed";

      if (e.message.toLowerCase().contains("already registered") ||
          e.message.toLowerCase().contains("user already registered")) {
        errorMessage = "This email is already registered!";
      } else if (e.message.toLowerCase().contains("invalid email")) {
        errorMessage = "Invalid email format";
      } else if (e.message.toLowerCase().contains("password")) {
        errorMessage = "Password requirements not met";
      } else {
        errorMessage = e.message;
      }

      Get.snackbar(
        "Error",
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      isLoading.value = false;

      Get.snackbar(
        "Error",
        "An unexpected error occurred",
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  // ---------------------------
  // SIGN IN (IMPROVED)
  // ---------------------------
  Future<void> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validation
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }

    // Email format validation
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Error",
        "Please enter a valid email address",
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      isLoading.value = false;

      if (response.user != null && response.session != null) {
        Get.snackbar(
          "Success",
          "Logged in successfully!",
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );

        // Clear the form
        emailController.clear();
        passwordController.clear();

        // Navigate to home or profile setup
        // Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          "Error",
          "Login failed. Please try again.",
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } on AuthException catch (e) {
      isLoading.value = false;

      // Handle specific auth errors
      String errorMessage = "Login failed";

      if (e.message.toLowerCase().contains("invalid login credentials") ||
          e.message.toLowerCase().contains("invalid credentials")) {
        errorMessage = "Invalid email or password!";
      } else if (e.message.toLowerCase().contains("email not confirmed")) {
        errorMessage = "Please confirm your email first";
      } else if (e.message.toLowerCase().contains("invalid email")) {
        errorMessage = "Invalid email format";
      } else {
        errorMessage = e.message;
      }

      Get.snackbar(
        "Error",
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      isLoading.value = false;

      Get.snackbar(
        "Error",
        "An unexpected error occurred",
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}