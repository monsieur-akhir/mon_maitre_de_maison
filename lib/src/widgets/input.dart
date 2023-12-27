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
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final int? maxLines; // Ajout de maxLines

  Input({
    this.placeholder,
    this.suffixIcon,
    this.prefixIcon,
    this.onTap,
    this.autofocus = false,
    this.borderColor = ArgonColors.border,
    this.controller,
    this.onFieldSubmitted,
    this.validator,
    this.obscureText = false,
    this.onChanged,
    this.maxLines, // Initialisez maxLines
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: ArgonColors.muted,
      onTap: onTap,
      onChanged: onChanged,
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines, // Utilisez maxLines ici
      style: TextStyle(height: 0.85, fontSize: 14.0, color: ArgonColors.initial),
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
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}

