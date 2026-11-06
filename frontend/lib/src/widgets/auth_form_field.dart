import 'package:flutter/material.dart';

/// Champ de formulaire avec libellé. Si [isPassword] est vrai, la saisie est
/// masquée et un bouton permet de l'afficher.
class AuthFormField extends StatefulWidget {
  const AuthFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.isPassword = false,
    this.forcedErrorText,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool isPassword;

  /// Erreur venant du serveur, affichée à la place de celle du [validator].
  final String? forcedErrorText;

  @override
  State<AuthFormField> createState() => _AuthFormFieldState();
}

class _AuthFormFieldState extends State<AuthFormField> {
  bool _isTextObscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword && _isTextObscured,
          onChanged: widget.onChanged,
          validator: widget.validator,
          forceErrorText: widget.forcedErrorText,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isTextObscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _isTextObscured = !_isTextObscured);
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
