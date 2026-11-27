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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordObscured = true;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Username is required';
    }
    if (trimmed.length < 2) {
      return 'Username must be at least 2 characters';
    }
    if (trimmed.length > 30) {
      return 'Username must be 30 characters or less';
    }
    return null;
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
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
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

    final success = await authProvider.signUp(
      _emailController.text.trim(),
      _passwordController.text,
      username: _usernameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      TextInput.finishAutofillContext();
      _usernameController.clear();
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

  void _handleGoogleSignUp() {
    FocusScope.of(context).unfocus();
    _showSnackBar(
      'Google sign-up is coming soon.',
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
                'Everything you need',
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
                'Create an account and start exploring',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary.copyWith(height: 1.4),
              ),
            ),
            SizedBox(height: isCompactHeight ? 22 : 28),
            const _FieldLabel(text: 'Username'),
            const SizedBox(height: 6),
            _buildUsernameField(isLoading),
            const SizedBox(height: 16),
            const _FieldLabel(text: 'Email'),
            const SizedBox(height: 6),
            _buildEmailField(isLoading),
            const SizedBox(height: 16),
            const _FieldLabel(text: 'Password'),
            const SizedBox(height: 6),
            _buildPasswordField(isLoading),
            const SizedBox(height: 24),
            Button(
              onPressed: isLoading ? null : _submitForm,
              title: 'Register',
              isLoading: isLoading,
            ),
            const SizedBox(height: 20),
            const LineDivider(),
            const SizedBox(height: 20),
            SocialAuthButton(
              image: 'https://img.icons8.com/?size=96&id=17949&format=png',
              text: 'Sign up with Google',
              onPressed: isLoading ? null : _handleGoogleSignUp,
            ),
            const SizedBox(height: 24),
            IgnorePointer(
              ignoring: isLoading,
              child: Opacity(
                opacity: isLoading ? 0.6 : 1,
                child: AuthBottomPrompt(
                  promptText: 'Already have an account? ',
                  actionText: 'Sign in',
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.login,
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

  Widget _buildUsernameField(bool isLoading) {
    return MyTextField(
      controller: _usernameController,
      focusNode: _usernameFocusNode,
      enabled: !isLoading,
      hintText: 'Enter your username',
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.username, AutofillHints.name],
      prefixIcon: const Icon(
        Icons.person_outline_rounded,
        color: AppColors.textHint,
        size: 20,
      ),
      onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
      validator: _validateUsername,
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
      hintText: 'Create a password',
      helperText: 'At least 6 characters',
      obscureText: _isPasswordObscured,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.newPassword],
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
