import 'package:flutter/material.dart';

/// Reusable validators for common form fields.
class Validators {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(
      TextEditingController original,
      ) {
    return (value) {
      if (value == null || value.isEmpty) return 'Please confirm your password';
      if (value != original.text) return 'Passwords do not match';
      return null;
    };
  }

  static String? Function(String?) required(String fieldName) {
    return (value) =>
    (value == null || value.trim().isEmpty) ? '$fieldName is required' : null;
  }
}

/// A highly reusable custom text field with built-in styling and state.
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final bool isPassword;
  final bool enabled;
  final AutovalidateMode? autovalidateMode;

  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.isPassword = false,
    this.enabled = true,
    this.autovalidateMode,
  });

  /// Email field with built-in validation.
  factory CustomTextField.email({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    String hintText = 'Enter your email',
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
    ValueChanged<String>? onFieldSubmitted,
    AutovalidateMode? autovalidateMode,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      prefixIcon: Icons.mail_outline,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.email],
      validator: validator ?? Validators.email,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: autovalidateMode,
    );
  }

  /// Password field with show/hide toggle.
  /// Set [isNewPassword] to true on sign-up / change-password screens.
  factory CustomTextField.password({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    String hintText = 'Enter your password',
    TextInputAction textInputAction = TextInputAction.done,
    bool isNewPassword = false,
    String? Function(String?)? validator,
    ValueChanged<String>? onFieldSubmitted,
    AutovalidateMode? autovalidateMode,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      prefixIcon: Icons.lock_outline,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      autofillHints: [
        isNewPassword ? AutofillHints.newPassword : AutofillHints.password,
      ],
      validator: validator ?? Validators.password,
      onFieldSubmitted: onFieldSubmitted,
      isPassword: true,
      autovalidateMode: autovalidateMode,
    );
  }

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  OutlineInputBorder _buildBorder(Color color, [double width = 1.0]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      obscureText: widget.isPassword && _obscure,
      autocorrect: false,
      enableSuggestions: false,
      autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(widget.prefixIcon),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.error)) return Colors.red;
          if (states.contains(WidgetState.focused)) return primary;
          return Colors.grey;
        }),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          color: Colors.grey,
          onPressed: () => setState(() => _obscure = !_obscure),
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: _buildBorder(Colors.indigo.shade100),
        enabledBorder: _buildBorder(Colors.indigo.shade100),
        focusedBorder: _buildBorder(primary, 2.0),
        errorBorder: _buildBorder(Colors.red),
        focusedErrorBorder: _buildBorder(Colors.red, 2.0),
      ),
    );
  }
}