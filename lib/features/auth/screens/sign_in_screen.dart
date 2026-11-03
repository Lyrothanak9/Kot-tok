import 'package:flutter/material.dart';
import 'package:kot_tok/app/theme/app_colors.dart';
import 'package:kot_tok/core/constants/logo.dart';
import 'package:provider/provider.dart';
import 'package:kot_tok/app/routes.dart';
import 'package:kot_tok/features/auth/providers/auth_provider.dart';
import 'package:kot_tok/features/auth/widgets/button.dart';
import 'package:kot_tok/features/auth/widgets/line_divider.dart';
import 'package:kot_tok/features/auth/widgets/social_auth_button.dart';
import 'package:kot_tok/features/auth/widgets/text_field.dart';

import '../widgets/auth_bottom_prompt.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        if (success) {
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
                SizedBox(height: 36,),
                const Center(child: Logo()),
                SizedBox(height: 16,),
                // Sign In Headers
                Center(
                  child: Text("Welcome back", style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.textTitleColor,
                  )),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text("Please enter your details.", style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimaryColor,
                  )),
                ),
                SizedBox(height: screenSize.height * 0.03),

                const SizedBox(height: 12),

                Text("Email", style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textTitleColor,
                )),
                const SizedBox(height: 8),
                _buildEmailField(),
                SizedBox(height: screenSize.height * 0.02),

                Text("Password", style:  Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textTitleColor,
                )),
                const SizedBox(height: 8),
                _buildPasswordField(),
                const SizedBox(height: 8),

                // Forgot Password Layout
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                    child: const Text("Forgot Password", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.03),

                Button(onPressed: isLoading ? null : _submitForm, title: "Log in", isLoading: isLoading),
                SizedBox(height: screenSize.height * 0.03),
                const LineDivider(),
                SizedBox(height: screenSize.height * 0.03),

                SocialAuthButton(
                  image: 'https://img.icons8.com/?size=96&id=17949&format=png',
                  text: 'Log in with google',
                  onPressed: () {},
                ),
                SizedBox(height: screenSize.height * 0.05),

                AuthBottomPrompt(
                  promptText: "Don't have an account? ",
                  actionText: "Sign up",
                  onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.signUp),
                ),
              ],
            ),
          ),
        ),
      ),
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
