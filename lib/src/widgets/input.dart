import 'package:flutter/material.dart';

import '../theme/theme.dart';

class Input extends StatelessWidget {
  final String? placeholder;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Function()? onTap;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final bool autofocus;
  final Color? borderColor;
  final ValueChanged<String>?
      onFieldSubmitted; // Ajout du callback pour la soumission
  final FormFieldValidator<String>? validator; // Ajout du validateur
  final bool obscureText;

  Input({
    this.placeholder,
    this.suffixIcon,
    this.prefixIcon,
    this.onTap,
    this.autofocus = false,
    this.borderColor = ArgonColors.border,
    this.controller,
    this.onFieldSubmitted,
    this.validator, // Initialisez le validateur
    this.obscureText = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // Utilisez TextFormField au lieu de TextField
      cursorColor: ArgonColors.muted,
      onTap: onTap,
      onChanged: onChanged,
      controller: controller,
      autofocus: autofocus,
      style:
          TextStyle(height: 0.85, fontSize: 14.0, color: ArgonColors.initial),
      textAlignVertical: TextAlignVertical(y: 0.6),
      decoration: InputDecoration(
        filled: true,
        fillColor: ArgonColors.white,
        hintStyle: TextStyle(
          color: ArgonColors.muted,
        ),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(
            color: borderColor!,
            width: 1.0,
            style: BorderStyle.solid,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(
            color: borderColor!,
            width: 1.0,
            style: BorderStyle.solid,
          ),
        ),
        hintText: placeholder,
      ),
      // Utilisez le validateur ici
      validator: validator,
      // Utilisez le callback pour la soumission ici
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
