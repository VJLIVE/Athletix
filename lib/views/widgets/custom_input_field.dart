import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'responsive_helper.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String fieldKey;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.fieldKey,
    required this.onTap,
    required this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool isobscure;
  @override
  void initState() {
    super.initState();
    isobscure = true;
  }
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.isSmallScreen(context) ? 10 : 12,
            ),
            border: Border.all(
              color: viewModel.getBorderColor(
                widget.fieldKey,
                hasText: widget.controller.text.isNotEmpty,
              ),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.suffixIcon != null ? isobscure : widget.obscureText,
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            style: TextStyle(
              fontSize:
                  ResponsiveHelper.isSmallScreen(context)
                      ? screenWidth * 0.035
                      : ResponsiveHelper.isMediumScreen(context)
                      ? screenWidth * 0.03
                      : screenWidth * 0.025,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: TextStyle(
                color: Colors.grey[600],
                fontSize:
                    ResponsiveHelper.isSmallScreen(context)
                        ? screenWidth * 0.035
                        : ResponsiveHelper.isMediumScreen(context)
                        ? screenWidth * 0.03
                        : screenWidth * 0.025,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.001,
              ),
              suffixIcon:
                  widget.suffixIcon != null ?
                  IconButton(onPressed: (){
                    setState(() {
                      isobscure = !isobscure;
                    });
                  }, icon: isobscure ? Icon(Icons.visibility_off) : Icon(Icons.visibility)) : null,
              errorText:
                  (!viewModel.isLogin &&
                          viewModel.formValidation.tappedFields[widget.fieldKey]!)
                      ? viewModel.formValidation.fieldErrors[widget.fieldKey]
                      : null,
              errorStyle: TextStyle(
                fontSize: ResponsiveHelper.isSmallScreen(context) ? 10 : 12,
              ),
            ),
          ),
        );
      },
    );
  }
}


