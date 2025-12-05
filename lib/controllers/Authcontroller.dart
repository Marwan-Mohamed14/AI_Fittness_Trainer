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
  // SIGNUP FUNCTION
  // ---------------------------
Future<void> signUp() async {
  final username = usernameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (username.isEmpty || email.isEmpty || password.isEmpty) {
    Get.snackbar("Error", "Please fill all fields");
    return;
  }

  isLoading.value = true;

  try {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {"username": username},
    );

    // Check if user is null (signup failed)
    if (response.user == null) {
      Get.snackbar("Signup Error", "Email already exists or signup failed!");
      return;
    }

    // Check if we have a session - if yes, signup was successful (email confirmation disabled)
    if (response.session != null) {
      Get.snackbar("Success", "Account created successfully!");
      return;
    }

    // If session is null, check if this is an existing user
    final user = response.user!;
    
    // Check 1: If email is already confirmed, it's definitely an existing user
    final emailConfirmedAt = user.emailConfirmedAt;
    if (emailConfirmedAt != null && emailConfirmedAt.isNotEmpty) {
      Get.snackbar("Signup Error", "Email already exists!");
      return;
    }
    
    // Check 2: If lastSignInAt exists, it means the user has logged in before (existing user)
    final lastSignInAt = user.lastSignInAt;
    if (lastSignInAt != null && lastSignInAt.isNotEmpty) {
      Get.snackbar("Signup Error", "Email already exists!");
      return;
    }
    
    // If email is not confirmed and no previous sign-in, it's a new signup
    // waiting for email confirmation
    Get.snackbar("Success", "Account created! Please check your email to confirm your account.");
  } on AuthException catch (e) {
    // Supabase throws AuthException for authentication errors
    String errorMessage = "Signup failed";
    final errorMsg = e.message.toLowerCase();
    final statusCode = e.statusCode;
    
    // Check for existing email errors
    if (errorMsg.contains("already registered") ||
        errorMsg.contains("user already exists") ||
        errorMsg.contains("email already") ||
        errorMsg.contains("already been registered") ||
        statusCode == 400 || 
        statusCode == 422) {
      errorMessage = "Email already exists!";
    } else {
      errorMessage = e.message.isNotEmpty ? e.message : "Signup failed. Please try again.";
    }
    Get.snackbar("Signup Error", errorMessage);
  } catch (e) {
    // Catch any other exceptions
    String errorMessage = e.toString().toLowerCase();
    if (errorMessage.contains("already registered") ||
        errorMessage.contains("user already exists") ||
        errorMessage.contains("email already") ||
        errorMessage.contains("already been registered")) {
      errorMessage = "Email already exists!";
    } else {
      errorMessage = "Signup failed: ${e.toString()}";
    }
    Get.snackbar("Signup Error", errorMessage);
  } finally {
    isLoading.value = false;
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
