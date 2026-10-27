import 'package:flutter/material.dart' hide TextField;
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'widgets/button.dart';
import 'widgets/image_profile_auth.dart';
import 'widgets/line_divider.dart';
import 'widgets/social_auth_button.dart';
import 'widgets/text_field.dart';

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
        _emailController.text,
        _passwordController.text,
      );
      if (success && mounted) {
        _emailController.clear();
        _passwordController.clear();
        _formKey.currentState?.reset();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign In Successful!'),
            backgroundColor: Colors.green,),
        );
        Navigator.pushReplacementNamed(context, '/main');
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
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.06,
                vertical: screenSize.height * 0.03,
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
                            title: "Sign In",
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.04),
                        Text(
                          "Email",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        _buildEmailField(),
                        SizedBox(height: screenSize.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Password",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              "Forget Password?",
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        _buildPasswordField(),
                        SizedBox(height: screenSize.height * 0.04),
                        Button(
                          onPressed: isLoading ? null : _submitForm,
                          title: "Sign In",
                          isLoading: isLoading,
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        const LineDivider(),
                        SizedBox(height: screenSize.height * 0.02),
                        _buildSocialAuth(),
                        const Spacer(),
                        SizedBox(height: screenSize.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Not registered yet? ",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.grey),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: Text(
                                "Sign Up >",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                  color: Theme.of(context).primaryColor,
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
