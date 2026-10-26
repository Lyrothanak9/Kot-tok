import 'package:flutter/material.dart' hide TextField;
import 'package:provider/provider.dart';

import '../../../../providers/auth_provider.dart';
import '../widgets/button.dart';
import '../widgets/image_profile_auth.dart';
import '../widgets/line_divider.dart';
import '../widgets/social_auth_button.dart';
import '../widgets/text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signUp(
        _emailController.text,
        _passwordController.text,
      );
      if (success && mounted) {
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _formKey.currentState?.reset();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (screenSize.height * 0.06),
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenSize.height * 0.02),
                        Center(
                          child: ImageProfileAuth(
                            avatarSize: screenSize.height * 0.13,
                            title: "Sign Up",
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.04),
                        Text(
                          "Email",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        _buildEmailField(),
                        const SizedBox(height: 20),
                        Text(
                          "Password",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        _buildPasswordField(),
                        const SizedBox(height: 20),
                        Text(
                          "Confirm Password",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        _buildConfirmPasswordField(),
                        const SizedBox(height: 32),
                        Button(
                          onPressed: isLoading ? null : _submitForm,
                          title: "Sign Up",
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 24),
                        const LineDivider(),
                        const SizedBox(height: 24),
                        _buildSocialAuth(),
                        const Spacer(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.grey),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacementNamed(context, '/login');
                                }
                              },
                              child: Text(
                                "Login",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
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
          },
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return MyTextField(
      controller: _emailController,
      hintText: "Enter your email",
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email cannot be empty';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return MyTextField(
      controller: _passwordController,
      hintText: "Enter your password",
      obscureText: _isPasswordObscured,
      keyboardType: TextInputType.visiblePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordObscured
              ? Icons.visibility_off
              : Icons.visibility,
          color: Colors.grey[400],
        ),
        onPressed: () {
          setState(() {
            _isPasswordObscured = !_isPasswordObscured;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password cannot be empty';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return MyTextField(
      controller: _confirmPasswordController,
      hintText: "Confirm your password",
      obscureText: _isConfirmPasswordObscured,
      keyboardType: TextInputType.visiblePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _isConfirmPasswordObscured
              ? Icons.visibility_off
              : Icons.visibility,
          color: Colors.grey[400],
        ),
        onPressed: () {
          setState(() {
            _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildSocialAuth() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialAuthButton(
          image:
          'https://img.icons8.com/?size=96&id=17949&format=png',
        ),
        SizedBox(width: 16),
        SocialAuthButton(
          image:
          "https://img.icons8.com/?size=100&id=30840&format=png&color=000000",
        ),
        SizedBox(width: 16),
        SocialAuthButton(
          image:
          "https://img.icons8.com/?size=100&id=13912&format=png&color=000000",
        ),
      ],
    );
  }
}
