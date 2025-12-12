import 'package:flutter/material.dart';
import 'package:rns_herbals_app/model/form_field_model.dart';

typedef ValidatorFn = String? Function(String? value);

class CustomTextField extends StatefulWidget {
  final FormFieldModel model;
  final TextEditingController controller;
  final ValidatorFn? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;


  final bool? readOnly;
  final int? maxLines;

  final Color borderColor;
  final Color cursorColor;
  final bool showClearButton; 
  final bool showPasswordToggle; 
  final bool autofocus;
  final Widget? trailing;

  const CustomTextField({
    super.key,
    required this.model,
    required this.controller,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly,
    this.maxLines,
    this.borderColor = Colors.blue,
    this.cursorColor = Colors.blue,
    this.showClearButton = false,
    this.showPasswordToggle = true,
    this.autofocus = false,
    this.trailing,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _obscure = widget.model.fieldType == FieldType.password;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  TextInputType _resolveKeyboardType() {
    if (widget.model.keyboardType != null) return widget.model.keyboardType!;
    switch (widget.model.fieldType) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.number:
        return TextInputType.number;
      case FieldType.phone:
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final effectiveReadOnly = widget.readOnly ?? widget.model.readOnly;
    final effectiveMaxLines = widget.maxLines ?? widget.model.maxLines;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: widget.borderColor),
    );

    Widget? suffix;
    final hasText = widget.controller.text.isNotEmpty;

    
    if (widget.trailing != null) {
      suffix = widget.trailing;
    } else if (widget.model.fieldType == FieldType.password && widget.showPasswordToggle) {
      suffix = IconButton(
        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    } else if (widget.model.suffixIcon != null) {
      suffix = Icon(widget.model.suffixIcon);
    } else if (widget.showClearButton && hasText && !effectiveReadOnly && widget.model.enabled) {
      suffix = IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          widget.controller.clear();
          widget.onChanged?.call('');
          setState(() {});
        },
      );
    }

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      enabled: widget.model.enabled,
      readOnly: effectiveReadOnly,
      cursorColor: widget.cursorColor,
      obscureText: _obscure,
      keyboardType: _resolveKeyboardType(),
      maxLines: effectiveMaxLines,
      maxLength: widget.model.maxLength,
      onTap: () {
     
        if (effectiveReadOnly) {
          FocusScope.of(context).requestFocus(FocusNode());
        }
        widget.onTap?.call();
      },
      validator: widget.validator ??
          (widget.model.required
              ? (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  return null;
                }
              : null),
      onChanged: (v) {
        setState(() {});
        widget.onChanged?.call(v);
      },
      decoration: InputDecoration(
        labelText: widget.model.label + (widget.model.required ? ' *' : ''),
        hintText: widget.model.hint,
        floatingLabelStyle: TextStyle(
          color: widget.borderColor,
          fontWeight: FontWeight.w600,
        ),
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: widget.model.prefixIcon != null ? Icon(widget.model.prefixIcon, color: widget.borderColor) : null,
        suffixIcon: suffix != null
            ? IconTheme(data: IconThemeData(color: widget.borderColor), child: suffix)
            : null,
        border: border,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.borderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }
}
