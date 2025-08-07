import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_state.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'custom_input_field.dart';
import 'password_checklist.dart';
import 'responsive_helper.dart';

class AuthForm extends StatelessWidget {
  const AuthForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return Column(
          children: [
            // Welcome Text
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  viewModel.isLogin ? 'Welcome Back,' : 'Create Account,',
                  style: TextStyle(
                    fontSize:
                        ResponsiveHelper.isSmallScreen(context)
                            ? screenWidth * 0.07
                            : ResponsiveHelper.isMediumScreen(context)
                            ? screenWidth * 0.06
                            : screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  viewModel.isLogin
                      ? 'Sign in to continue'
                      : 'Sign up to get started',
                  style: TextStyle(
                    fontSize:
                        ResponsiveHelper.isSmallScreen(context)
                            ? screenWidth * 0.035
                            : ResponsiveHelper.isMediumScreen(context)
                            ? screenWidth * 0.03
                            : screenWidth * 0.025,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(
              height:
                  screenHeight *
                  (ResponsiveHelper.isSmallScreen(context) ? 0.04 : 0.05),
            ),

            // Form Container
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.getResponsiveWidth(context),
              ),
              padding: EdgeInsets.all(
                ResponsiveHelper.isSmallScreen(context)
                    ? screenWidth * 0.04
                    : ResponsiveHelper.isMediumScreen(context)
                    ? screenWidth * 0.045
                    : screenWidth * 0.05,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.isSmallScreen(context) ? 16 : 20,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius:
                        ResponsiveHelper.isSmallScreen(context) ? 8 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Signup-only fields
                  if (!viewModel.isLogin) ...[
                    CustomInputField(
                      controller: viewModel.nameController,
                      label: "Full Name",
                      fieldKey: 'name',
                      onTap: () => viewModel.onFieldTapped('name'),
                      onChanged:
                          (value) => viewModel.onFieldChanged('name', value),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Date of Birth Field
                    GestureDetector(
                      onTap: () async {
                        viewModel.onFieldTapped('dob');
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: viewModel.dob ?? DateTime(2000),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          viewModel.setDob(picked);
                        }
                      },
                      child: AbsorbPointer(
                        child: CustomInputField(
                          controller: viewModel.dobController,
                          label: "Date of Birth",
                          fieldKey: 'dob',
                          suffixIcon: Icons.calendar_today,
                          onTap: () => viewModel.onFieldTapped('dob'),
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Role Dropdown
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.isSmallScreen(context) ? 10 : 12,
                        ),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: viewModel.selectedRole,
                        decoration: InputDecoration(
                          labelText: "Role",
                          labelStyle: TextStyle(
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
                            vertical: screenHeight * 0.01,
                          ),
                        ),
                        items:
                            viewModel.roles
                                .map(
                                  (role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) => viewModel.setSelectedRole(value!),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Sport/Specialization Field
                    if (viewModel.selectedRole == 'Doctor')
                      CustomInputField(
                        controller: viewModel.sportController,
                        label: "Specialization",
                        fieldKey: 'sport',
                        onTap: () => viewModel.onFieldTapped('sport'),
                        onChanged:
                            (value) => viewModel.onFieldChanged('sport', value),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.isSmallScreen(context) ? 10 : 12,
                          ),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonFormField<String>(
                          value:
                              viewModel.sportController.text.isNotEmpty
                                  ? viewModel.sportController.text
                                  : null,
                          decoration: InputDecoration(
                            labelText: "Sport",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.01,
                            ),
                          ),
                          items:
                              viewModel.sports
                                  .map(
                                    (sport) => DropdownMenuItem(
                                      value: sport,
                                      child: Text(sport),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) => viewModel.setSport(value ?? ''),
                        ),
                      ),
                    SizedBox(height: screenHeight * 0.02),
                  ],

                  // Email Field
                  CustomInputField(
                    controller: viewModel.emailController,
                    label: "Email",
                    fieldKey: 'email',
                    onTap: () => viewModel.onFieldTapped('email'),
                    onChanged:
                        (value) => viewModel.onFieldChanged('email', value),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Password Field
                  CustomInputField(
                    controller: viewModel.passwordController,
                    label: "Password",
                    fieldKey: 'password',
                    suffixIcon: Icons.visibility_off,
                    onTap: () => viewModel.onFieldTapped('password'),
                    onChanged:
                        (value) => viewModel.onFieldChanged('password', value),
                  ),

                  // Password Checklist for Signup
                  if (!viewModel.isLogin &&
                      viewModel.formValidation.tappedFields['password']!) ...[
                    SizedBox(height: screenHeight * 0.02),
                    const PasswordChecklist(),
                  ],

                  // Forgot Password for Login
                  if (viewModel.isLogin) ...[
                    SizedBox(height: screenHeight * 0.005),
                  ],

                  SizedBox(height: screenHeight * 0.02),

                  // Auth Button
                  Container(
                    width: double.infinity,
                    height:
                        ResponsiveHelper.isSmallScreen(context)
                            ? screenHeight * 0.06
                            : ResponsiveHelper.isMediumScreen(context)
                            ? screenHeight * 0.065
                            : screenHeight * 0.07,
                    child: ElevatedButton(
                      onPressed:
                          viewModel.authState.status == AuthStatus.loading
                              ? null
                              : viewModel.handleAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.isSmallScreen(context) ? 10 : 12,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child:
                          viewModel.authState.status == AuthStatus.loading
                              ? SizedBox(
                                height:
                                    ResponsiveHelper.isSmallScreen(context)
                                        ? 18
                                        : 20,
                                width:
                                    ResponsiveHelper.isSmallScreen(context)
                                        ? 18
                                        : 20,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                viewModel.isLogin ? "Login" : "Signup",
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.isSmallScreen(context)
                                          ? screenWidth * 0.04
                                          : ResponsiveHelper.isMediumScreen(
                                            context,
                                          )
                                          ? screenWidth * 0.035
                                          : screenWidth * 0.03,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),

                  SizedBox(
                    height:
                        screenHeight *
                        (ResponsiveHelper.isSmallScreen(context)
                            ? 0.025
                            : 0.03),
                  ),

                  // Toggle Auth Mode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        viewModel.isLogin
                            ? 'New user? '
                            : 'Already have an account? ',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize:
                              ResponsiveHelper.isSmallScreen(context)
                                  ? screenWidth * 0.03
                                  : ResponsiveHelper.isMediumScreen(context)
                                  ? screenWidth * 0.025
                                  : screenWidth * 0.02,
                        ),
                      ),
                      GestureDetector(
                        onTap: viewModel.toggleAuthMode,
                        child: Text(
                          viewModel.isLogin ? 'Signup' : 'Login',
                          style: TextStyle(
                            color: const Color(0xFFFF6B6B),
                            fontSize:
                                ResponsiveHelper.isSmallScreen(context)
                                    ? screenWidth * 0.03
                                    : ResponsiveHelper.isMediumScreen(context)
                                    ? screenWidth * 0.025
                                    : screenWidth * 0.02,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
