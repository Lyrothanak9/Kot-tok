import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kot_tok/app/routes.dart';
import 'package:kot_tok/app/theme/app_colors.dart';
import 'package:kot_tok/app/theme/text_styles.dart';
import 'package:kot_tok/core/constants/logo.dart';
import 'package:kot_tok/features/auth/providers/auth_provider.dart';
import 'package:kot_tok/features/auth/widgets/auth_bottom_prompt.dart';
import 'package:kot_tok/features/auth/widgets/button.dart';
import 'package:kot_tok/features/auth/widgets/line_divider.dart';
import 'package:kot_tok/features/auth/widgets/social_auth_button.dart';
import 'package:kot_tok/features/auth/widgets/text_field.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordObscured = true;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  void _showSnackBar(String message, {required Color backgroundColor}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoading) return;

    if (!_formKey.currentState!.validate()) {
      if (_autovalidateMode != AutovalidateMode.onUserInteraction) {
        setState(() {
          _autovalidateMode = AutovalidateMode.onUserInteraction;
        });
      }
      return;
    }

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      TextInput.finishAutofillContext();
      _emailController.clear();
      _passwordController.clear();
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else if (authProvider.errorMessage != null) {
      _showSnackBar(
        authProvider.errorMessage!,
        backgroundColor: AppColors.error,
      );
    }
  }

  void _handleGoogleSignIn() {
    FocusScope.of(context).unfocus();
    _showSnackBar(
      'Google sign-in is coming soon.',
      backgroundColor: AppColors.textPrimary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final screenSize = MediaQuery.sizeOf(context);
    final isTabletOrDesktop = screenSize.width >= 600;
    final isCompactHeight = screenSize.height < 720;

    final formContent = AutofillGroup(
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(child: Logo()),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Welcome back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: AppColors.textTitleColor,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Please enter your details.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary.copyWith(height: 1.4),
              ),
            ),
            SizedBox(height: isCompactHeight ? 22 : 28),
            const _FieldLabel(text: 'Email'),
            const SizedBox(height: 6),
            _buildEmailField(isLoading),
            const SizedBox(height: 16),
            const _FieldLabel(text: 'Password'),
            const SizedBox(height: 6),
            _buildPasswordField(isLoading),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () => Navigator.pushNamed(
                          context,
                          AppRoutes.forgotPassword,
                        ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  minimumSize: const Size(48, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Button(
              onPressed: isLoading ? null : _submitForm,
              title: 'Log in',
              isLoading: isLoading,
            ),
            const SizedBox(height: 20),
            const LineDivider(),
            const SizedBox(height: 20),
            SocialAuthButton(
              image: 'https://img.icons8.com/?size=96&id=17949&format=png',
              text: 'Log in with Google',
              onPressed: isLoading ? null : _handleGoogleSignIn,
            ),
            const SizedBox(height: 24),
            IgnorePointer(
              ignoring: isLoading,
              child: Opacity(
                opacity: isLoading ? 0.6 : 1,
                child: AuthBottomPrompt(
                  promptText: "Don't have an account? ",
                  actionText: 'Sign up',
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.signUp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor:
          isTabletOrDesktop ? const Color(0xFFF7F8FC) : AppColors.background,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTabletOrDesktop ? 24 : 20,
                        vertical: isCompactHeight ? 16 : 24,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: isTabletOrDesktop
                            ? Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: formContent,
                              )
                            : formContent,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField(bool isLoading) {
    return MyTextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      enabled: !isLoading,
      hintText: 'Enter your email',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      prefixIcon: const Icon(
        Icons.mail_outline_rounded,
        color: AppColors.textHint,
        size: 20,
      ),
      onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
      validator: _validateEmail,
    );
  }

  Widget _buildPasswordField(bool isLoading) {
    return MyTextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      enabled: !isLoading,
      hintText: 'Enter your password',
      obscureText: _isPasswordObscured,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        color: AppColors.textHint,
        size: 20,
      ),
      suffixIcon: IconButton(
        tooltip: _isPasswordObscured ? 'Show password' : 'Hide password',
        icon: Icon(
          _isPasswordObscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.textHint,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _isPasswordObscured = !_isPasswordObscured;
          });
        },
      ),
      onFieldSubmitted: (_) => _submitForm(),
      validator: _validatePassword,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
