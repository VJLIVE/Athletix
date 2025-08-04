import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'responsive_helper.dart';

class CustomInputField extends StatelessWidget {
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
                fieldKey,
                hasText: controller.text.isNotEmpty,
              ),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            onTap: onTap,
            onChanged: onChanged,
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
              labelText: label,
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
                  suffixIcon != null
                      ? Icon(
                        suffixIcon,
                        color: Colors.grey[600],
                        size:
                            ResponsiveHelper.isSmallScreen(context)
                                ? screenWidth * 0.045
                                : ResponsiveHelper.isMediumScreen(context)
                                ? screenWidth * 0.04
                                : screenWidth * 0.035,
                      )
                      : null,
              errorText:
                  (!viewModel.isLogin &&
                          viewModel.formValidation.tappedFields[fieldKey]!)
                      ? viewModel.formValidation.fieldErrors[fieldKey]
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
