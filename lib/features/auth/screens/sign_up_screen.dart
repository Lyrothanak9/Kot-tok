import 'package:flutter/material.dart';
import 'package:kot_tok/core/constants/logo.dart';
import 'package:provider/provider.dart';
import 'package:kot_tok/app/routes.dart';
import 'package:kot_tok/features/auth/providers/auth_provider.dart';
import 'package:kot_tok/features/auth/widgets/button.dart';
import 'package:kot_tok/features/auth/widgets/line_divider.dart';
import 'package:kot_tok/features/auth/widgets/social_auth_button.dart';
import 'package:kot_tok/features/auth/widgets/text_field.dart';
import '../../../app/theme/app_colors.dart';

import '../widgets/auth_bottom_prompt.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        if (success) {
          _usernameController.clear();
          _emailController.clear();
          _passwordController.clear();
          Navigator.pushReplacementNamed(context, AppRoutes.main);
        } else if (authProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 36),
                const Center(child:Logo()),
                SizedBox(height: 16),

                // Sign Up Headers
                Center(
                  child: Text("Everything you need", style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.textTitleColor,
                  )),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text("Create an account and start exploring", style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimaryColor,
                  )),
                ),
                SizedBox(height: screenSize.height * 0.03),

                const SizedBox(height: 12),

                // Username field specific to Sign Up
                const Text("Username", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildUsernameField(),
                SizedBox(height: screenSize.height * 0.02),

                const Text("Email", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildEmailField(),
                SizedBox(height: screenSize.height * 0.02),

                const Text("Password", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildPasswordField(),
                SizedBox(height: screenSize.height * 0.04),

                Button(onPressed: isLoading ? null : _submitForm, title: "Register", isLoading: isLoading),
                SizedBox(height: screenSize.height * 0.03),
                const LineDivider(),
                SizedBox(height: screenSize.height * 0.03),

                SocialAuthButton(
                  image: 'https://img.icons8.com/?size=96&id=17949&format=png',
                  text: 'Sign Up with google',
                  onPressed: () {},
                ),
                SizedBox(height: screenSize.height * 0.05),

                AuthBottomPrompt(
                  promptText: "Already have an account? ",
                  actionText: "Sign in",
                  onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildUsernameField() {
    return MyTextField(
      controller: _usernameController,
      hintText: "enter your username",
      keyboardType: TextInputType.name,
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildEmailField() {
    return MyTextField(
      controller: _emailController,
      hintText: "enter your email",
      keyboardType: TextInputType.emailAddress,
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildPasswordField() {
    return MyTextField(
      controller: _passwordController,
      hintText: "enter password",
      obscureText: _isPasswordObscured,
      keyboardType: TextInputType.visiblePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey,
        ),
        onPressed: () {
          setState(() {
            _isPasswordObscured = !_isPasswordObscured;
          });
        },
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }
}
