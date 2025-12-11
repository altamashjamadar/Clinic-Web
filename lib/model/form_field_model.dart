// lib/models/form_field_model.dart

import 'package:flutter/material.dart';

enum FieldType {
  text,
  email,
  number,
  phone,
  password,
}

class FormFieldModel {
  final String name; // optional identifier
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon; // used if you want a static suffix icon
  final FieldType fieldType;
  final bool required;
  final bool enabled;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final bool readOnly;

  final String? floatingLabelStyle;

  const FormFieldModel({
    this.name = '',
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.fieldType = FieldType.text,
    this.required = false,
    this.enabled = true,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.floatingLabelStyle,
  });
}
