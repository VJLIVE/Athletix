import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'responsive_helper.dart';

class PasswordChecklist extends StatelessWidget {
  const PasswordChecklist({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChecklistItem(
              "At least 8 characters",
              viewModel.formValidation.hasMinLength,
              screenWidth,
              context,
            ),
            _buildChecklistItem(
              "Contains uppercase letter",
              viewModel.formValidation.hasUppercase,
              screenWidth,
              context,
            ),
            _buildChecklistItem(
              "Contains lowercase letter",
              viewModel.formValidation.hasLowercase,
              screenWidth,
              context,
            ),
            _buildChecklistItem(
              "Contains a number",
              viewModel.formValidation.hasNumber,
              screenWidth,
              context,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChecklistItem(
    String text,
    bool isValid,
    double screenWidth,
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.005),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size:
                ResponsiveHelper.isSmallScreen(context)
                    ? 18
                    : ResponsiveHelper.isMediumScreen(context)
                    ? 20
                    : 22,
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isValid ? Colors.green : Colors.red,
                fontSize:
                    ResponsiveHelper.isSmallScreen(context)
                        ? 12
                        : ResponsiveHelper.isMediumScreen(context)
                        ? 14
                        : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
