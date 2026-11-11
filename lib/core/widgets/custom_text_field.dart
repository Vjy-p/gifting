import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void fieldFocusChange({
  required BuildContext context,
  required FocusNode currentFocus,
  FocusNode? nextFocus,
}) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    this.icon,
    this.suffixIcon,
    required this.controller,
    required this.currentFocus,
    this.nextFocus,
    this.borderColor,
    this.borderRadius,
    this.textColor,
    this.keyboardType,
    this.enable = true,
    this.inputAction,
    this.isEmail = false,
    this.isMobileNumber = false,
    this.isNumber = false,
    this.isPassword = false,
    this.maxLines,
    this.maxCount = 200,
    this.validate = true,
    this.onChanged,
    this.onFieldSubmitted,
    this.passwordText,
    this.isObscureText = false,
    this.isConfirmPassword = false,
  });

  final String label;
  final Icon? icon;
  final Widget? suffixIcon;
  final TextEditingController controller;
  final FocusNode currentFocus;
  final FocusNode? nextFocus;
  final Color? borderColor;
  final double? borderRadius;
  final Color? textColor;
  final TextInputType? keyboardType;
  final bool enable;
  final TextInputAction? inputAction;
  final bool isEmail;
  final bool isPassword;
  final bool isObscureText;
  final bool isConfirmPassword;
  final bool isMobileNumber;
  final bool isNumber;
  final int? maxLines;
  final int? maxCount;
  final bool validate;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? passwordText;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            // color: textColor ?? CustomColors.textColor,
          ),
        ),
        TextFormField(
          keyboardType: isMobileNumber || isNumber
              ? const TextInputType.numberWithOptions()
              : keyboardType ?? TextInputType.text,
          // style: TextStyle(color: textColor ?? CustomColors.textColor),
          controller: controller,
          focusNode: currentFocus,
          maxLines: isPassword || isConfirmPassword || isMobileNumber
              ? 1
              : maxLines,
          maxLength: isMobileNumber ? 10 : maxCount,
          textCapitalization: isMobileNumber || isNumber
              ? TextCapitalization.none
              : TextCapitalization.words,
          textInputAction:
              inputAction ??
              (nextFocus != null ? TextInputAction.next : TextInputAction.done),
          inputFormatters: isMobileNumber || isNumber
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          obscureText: isObscureText,
          decoration: InputDecoration(
            enabled: enable,
            isDense: true,
            counterText: '',
            visualDensity: VisualDensity.comfortable,
            hintText: 'Enter $label',
            // hintStyle: TextStyle(
            //   color: textColor ?? CustomColors.textColor.withValues(alpha: 0.6),
            // ),
            prefixIcon: icon,
            suffixIcon: suffixIcon,
            // border: OutlineInputBorder(
            //   borderSide: BorderSide(
            //     color: borderColor ?? CustomColors.textColor,
            //   ),
            //   borderRadius: BorderRadius.circular(borderRadius ?? 10),
            // ),
            // enabledBorder: OutlineInputBorder(
            //   borderSide: BorderSide(
            //     color: borderColor ?? CustomColors.textColor,
            //   ),
            //   borderRadius: BorderRadius.circular(borderRadius ?? 10),
            // ),
            // focusedBorder: OutlineInputBorder(
            //   borderSide: BorderSide(
            //     color: borderColor ?? CustomColors.textColor,
            //   ),
            //   borderRadius: BorderRadius.circular(borderRadius ?? 10),
            // ),
            // disabledBorder: OutlineInputBorder(
            //   borderSide: BorderSide(
            //     color: borderColor ?? CustomColors.textColor,
            //   ),
            //   borderRadius: BorderRadius.circular(borderRadius ?? 10),
            // ),
            // focusedErrorBorder: OutlineInputBorder(
            //   borderSide: BorderSide(
            //     color: borderColor ?? CustomColors.textColor,
            //   ),
            //   borderRadius: BorderRadius.circular(borderRadius ?? 10),
            // ),
            // errorBorder: OutlineInputBorder(
            //   borderSide: BorderSide(color: CustomColors.redColor),
            //   borderRadius: BorderRadius.circular(borderRadius ?? 10),
            // ),
            filled: true,
            // fillColor: CustomColors.lightColor,
          ),
          onChanged: onChanged,
          onFieldSubmitted:
              onFieldSubmitted ??
              (value) {
                fieldFocusChange(
                  context: context,
                  currentFocus: currentFocus,
                  nextFocus: nextFocus,
                );
              },
          onTapOutside: (event) {
            if (FocusManager.instance.primaryFocus!.hasFocus) {
              currentFocus.unfocus();
            }
          },
          validator: validate
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return label.toLowerCase().contains('Enter')
                        ? 'Enter ${label.substring(5).toLowerCase()}'
                        : 'Enter ${label.toLowerCase()}';
                  } else if (isEmail) {
                    return GetUtils.isEmail(value.toString())
                        ? null
                        : 'Enter correct email';
                  } else if (isMobileNumber &&
                      (value.length < 10 ||
                          (value.isNotEmpty && int.parse(value) < 5))) {
                    return 'Enter correct mobile number';
                  } else if (isPassword) {
                    if (value.length < 8) {
                      return 'Password must be greaterthan 8 characters';
                    } else {
                      return null;
                    }
                  } else if (isConfirmPassword) {
                    log('values  $passwordText $value');
                    if (passwordText == value.trim()) {
                      return null;
                    } else {
                      return 'Password must be same';
                    }
                  } else {
                    return null;
                  }
                }
              : null,
        ),
      ],
    );
  }
}

class CustomDropDownField extends StatelessWidget {
  const CustomDropDownField({
    super.key,
    required this.label,
    required this.icon,
    this.suffixIcon,
    required this.initialValue,
    required this.currentFocus,
    this.nextFocus,
    required this.items,
    required this.onSaved,
  });

  final String label;
  final Icon icon;
  final Widget? suffixIcon;
  final String? initialValue;
  final FocusNode currentFocus;
  final FocusNode? nextFocus;
  final List items;
  final Function(dynamic) onSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            // color: textColor ?? CustomColors.textColor,
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: initialValue,
          focusNode: currentFocus,
          isDense: true,
          decoration: InputDecoration(
            isDense: true,
            hintText: label,
            prefixIcon: icon,
            suffixIcon: suffixIcon,
            counterText: '',
            visualDensity: VisualDensity.comfortable,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item.toString(),
                  child: Text(item.toString()),
                ),
              )
              .toList(),
          onChanged: (value) {
            onSaved(value);
            fieldFocusChange(
              context: context,
              currentFocus: currentFocus,
              nextFocus: nextFocus,
            );
          },
          validator: (value) => value == null ? 'Select a $label' : null,
        ),
      ],
    );
  }
}
