import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stray_resuce_bih/core/theme/app_theme.dart';
import 'package:stray_resuce_bih/features/auth/screens/login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<String> _sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return "Success";
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors
      switch (e.code) {
        case 'user-not-found':
          return "No user found with this email.";
        case 'invalid-email':
          return "The email address is not valid.";
        default:
          return "Error: ${e.message}";
      }
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  void _resetPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar("Please enter your email.");
      return;
    }

    setState(() => _isLoading = true);

    // Call the helper function as requested
    final result = await _sendPasswordResetEmail(email);
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == "Success") {
      _showSnackBar("Password reset email sent! Check your inbox.");
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      });
    } else {
      _showSnackBar(result); // Show the specific error message returned
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('sent') ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      )
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Reset Your Password',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: AppTheme.primaryOrange
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter your registered email to receive a password reset link.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
                  : ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Send Reset Link',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
