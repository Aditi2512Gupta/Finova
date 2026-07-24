import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../navigation/main_navigation_screen.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient glowing background mesh blobs
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Blur filter overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 75.0, sigmaY: 75.0),
                child: Container(color: Colors.transparent),
              ),
            ),

            // Scrollable signup contents
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: themeProvider.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 12),

                  // Brand Header Title
                  Center(
                    child: Text(
                      "Finova",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: themeProvider.textPrimary,
                        fontFamily: 'Outfit',
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Title and Subtitle
                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textPrimary,
                      fontFamily: 'Outfit',
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Sign up to start tracking your finances with dynamic budgets, wallet syncing, and AI coach.",
                    style: TextStyle(
                      color: themeProvider.textSecondary,
                      fontSize: 14.5,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Unified Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: themeProvider.surfaceColor.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: themeProvider.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.015),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Input
                        Text(
                          "Full Name",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textPrimary,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          style: TextStyle(color: themeProvider.textPrimary),
                          decoration: InputDecoration(
                            hintText: "e.g. Aditi Gupta",
                            hintStyle: TextStyle(
                              color: themeProvider.textSecondary.withOpacity(
                                0.35,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: themeProvider.textSecondary.withOpacity(
                                0.7,
                              ),
                              size: 20,
                            ),
                            filled: true,
                            fillColor: themeProvider.backgroundColor
                                .withOpacity(0.5),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: themeProvider.borderColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: themeProvider.borderColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: themeProvider.primaryColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Email Input
                        Text(
                          "Email Address",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textPrimary,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: themeProvider.textPrimary),
                          decoration: InputDecoration(
                            hintText: "e.g. aditi@finova.com",
                            hintStyle: TextStyle(
                              color: themeProvider.textSecondary.withOpacity(
                                0.35,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: themeProvider.textSecondary.withOpacity(
                                0.7,
                              ),
                              size: 20,
                            ),
                            filled: true,
                            fillColor: themeProvider.backgroundColor
                                .withOpacity(0.5),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: themeProvider.borderColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: themeProvider.borderColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: themeProvider.primaryColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Password Input
                        Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textPrimary,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          style: TextStyle(color: themeProvider.textPrimary),
                          decoration: InputDecoration(
                            hintText: "Create a password",
                            hintStyle: TextStyle(
                              color: themeProvider.textSecondary.withOpacity(
                                0.35,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: themeProvider.textSecondary.withOpacity(
                                0.7,
                              ),
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: themeProvider.textSecondary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: themeProvider.backgroundColor
                                .withOpacity(0.5),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: themeProvider.borderColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: themeProvider.borderColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: themeProvider.primaryColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: themeProvider.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (nameController.text.trim().isEmpty ||
                                  emailController.text.trim().isEmpty ||
                                  passwordController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please fill in all fields"),
                                  ),
                                );
                                return;
                              }

                              setState(() => isLoading = true);

                              try {
                                await _authService.signUp(
                                  name: nameController.text.trim(),
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );

                                await Provider.of<ThemeProvider>(
                                  context,
                                  listen: false,
                                ).loadUserPreferences();

                                if (mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const MainNavigationScreen(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceAll(
                                          "Exception: ",
                                          "",
                                        ),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => isLoading = false);
                                }
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Sign In link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: themeProvider.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
