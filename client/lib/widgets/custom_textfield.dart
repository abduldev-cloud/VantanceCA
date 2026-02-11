import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';

/// Custom Text Input Fields
class TextInputFields extends StatefulWidget {
  /// Constructs a new TextInputFields
  const TextInputFields(
      {super.key,
      this.suffixWidget,
      this.fillColor,
      this.prefixWidget,
      this.keyboardType,
      this.validator,
      this.controller,
      this.obSecureText,
      this.onTap,
      this.readOnly = false,
      this.contentPadding,
      this.textAlign,
      this.name,
      this.hintText,
      this.suffix,
      this.focusNode,
      this.nameColor,
      this.hintTextStyle,
      this.textStyle,
      this.titleTextStyle,
      this.suffixIconConstraints,
      this.filled,
      this.borderColor,
      this.onChanged,
      this.initialValue,
      this.errorStyle,
      this.maxLine = 1,
      this.fontSize,
      this.onFieldSubmitted,
      this.prefixIconConstraints,
      this.inputFormatters,
      this.titleWidget,
      this.autofillHints,
      this.enabledBorder,
      this.focusedBorder,
      this.errorBorder,
      this.focusedErrorBorder});

  /// Suffix widget
  final Widget? suffixWidget;
  final Iterable<String>? autofillHints;

  /// Prefix widget
  final Widget? prefixWidget;
  final Widget? titleWidget;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Validator
  final String? Function(String?)? validator;

  /// TextEditing controller
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final bool? obSecureText;
  final VoidCallback? onTap;
  final TextAlign? textAlign;
  final TextStyle? errorStyle;
  final double? fontSize;
  final bool readOnly;
  final Color? fillColor;
  final String? name;
  final String? initialValue;
  final EdgeInsetsGeometry? contentPadding;
  final String? hintText;
  final Widget? suffix;
  final FocusNode? focusNode;
  final Color? nameColor;
  final TextStyle? hintTextStyle;
  final Function(String)? onChanged;
  final TextStyle? textStyle;
  final TextStyle? titleTextStyle;
  final bool? filled;
  final Color? borderColor;
  final BoxConstraints? suffixIconConstraints;
  final BoxConstraints? prefixIconConstraints;
  final int maxLine;
  final Function(String)? onFieldSubmitted;
  
  // Custom Borders
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;

  @override
  State<TextInputFields> createState() => _TextInputFieldsState();
}

class _TextInputFieldsState extends State<TextInputFields>
    with SingleTickerProviderStateMixin, UIMixin {
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.name != null)
            widget.titleWidget ??
                Text(
                  widget.name!,
                  style: widget.titleTextStyle ??
                      GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: contentTheme.k181818),
                ),
          if (widget.name != null) MySpacing.height(6),
          TextFormField(
            autofillHints: widget.autofillHints,
            onFieldSubmitted: widget.onFieldSubmitted,
            initialValue: widget.initialValue,
            textCapitalization: TextCapitalization.sentences,
            readOnly: widget.readOnly,
            textAlign: widget.textAlign ?? TextAlign.start,
            style: widget.textStyle ??
                GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: contentTheme.black),
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            obscureText: widget.obSecureText ?? false,
            controller: widget.controller,
            keyboardType: widget.keyboardType,

            // enabled: readOnly,
            cursorColor: Colors.black,
            validator: widget.validator,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.maxLine,
            decoration: InputDecoration(
              fillColor: widget.fillColor ?? Colors.white,
              filled: widget.filled,
              hintText: widget.hintText,
              hintStyle: widget.hintTextStyle ??
                  GoogleFonts.inter(
                      fontWeight: FontWeight.w300,
                      fontSize: 12.sp,
                      color: Color(0xff636364)),
              errorMaxLines: 2,
              errorStyle: widget.errorStyle,
              contentPadding: widget.contentPadding ??
                  EdgeInsets.only(
                      bottom: 20.h, top: 20.h, left: 15.w, right: 10.w),
              border: border,
              isDense: true,
              isCollapsed: true,
              focusedErrorBorder: widget.focusedErrorBorder ?? OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(
                    width: 1, color: widget.borderColor ?? Color(0xffC6C3C3)),
              ),
              suffixIconConstraints: widget.suffixIconConstraints,
              disabledBorder: border,
              focusedBorder: widget.focusedBorder ?? border,
              errorBorder: widget.errorBorder ?? OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(
                  width: 1,
                  color: widget.borderColor ?? contentTheme.red,
                ),
              ),
              prefixIconConstraints: widget.prefixIconConstraints,
              suffix: widget.suffix,
              enabledBorder: widget.enabledBorder ?? border,
              suffixIcon: widget.suffixWidget,
              prefixIcon: widget.prefixWidget,
            ),
          ),
        ],
      );

  /// Border
  OutlineInputBorder get border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
            width: 1, color: widget.borderColor ?? Color(0xffC6C3C3)),
      );
}
