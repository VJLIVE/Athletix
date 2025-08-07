class ValidationService {
  static String? validateEmail(
    String email, {
    bool forceValidate = false,
    bool fieldTapped = false,
  }) {
    if (email.isEmpty && (forceValidate || fieldTapped)) {
      return "Email is required";
    } else if (email.isNotEmpty) {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@(gmail\.com|yahoo\.com|outlook\.com)$',
      );
      if (!emailRegex.hasMatch(email)) {
        return "Use a valid email (e.g., @gmail.com, @yahoo.com, @outlook.com)";
      }
    }
    return null;
  }

  static String? validatePassword(
    String password, {
    bool isLogin = false,
    bool forceValidate = false,
    bool fieldTapped = false,
  }) {
    if (!isLogin) {
      if (password.isEmpty && (forceValidate || fieldTapped)) {
        return "Password is required";
      } else if (password.isNotEmpty) {
        if (password.length < 8)
          return "Password must be at least 8 characters long";
        if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
          return "Password must contain at least one uppercase letter";
        }
        if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
          return "Password must contain at least one lowercase letter";
        }
        if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
          return "Password must contain at least one number";
        }
      }
    } else {
      if (password.isEmpty && (forceValidate || fieldTapped)) {
        return "Password is required";
      }
    }
    return null;
  }

  static String? validateName(
    String name, {
    bool forceValidate = false,
    bool fieldTapped = false,
  }) {
    if (name.isEmpty && (forceValidate || fieldTapped)) {
      return "Full name is required";
    } else if (name.isNotEmpty) {
      if (name.length < 4) return "Name must be at least 4 characters long";
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
        return "Name can only contain letters and spaces";
      }
    }
    return null;
  }

  static String? validateSport(
    String sport,
    String role, {
    bool forceValidate = false,
    bool fieldTapped = false,
  }) {
    if (sport.isEmpty && (forceValidate || fieldTapped)) {
      return role == 'Doctor'
          ? "Specialization is required"
          : "Sport is required";
    }
    return null;
  }

  static String? validateDob(
    DateTime? dob, {
    bool forceValidate = false,
    bool fieldTapped = false,
  }) {
    if (dob == null && (forceValidate || fieldTapped)) {
      return "Date of birth is required";
    } else if (dob != null) {
      final now = DateTime.now();
      final age =
          now.year -
          dob.year -
          (now.month > dob.month ||
                  (now.month == dob.month && now.day >= dob.day)
              ? 0
              : 1);
      if (age < 13) return "You must be at least 13 years old";
    }
    return null;
  }

  static Map<String, bool> getPasswordChecklist(String password) {
    return {
      'hasUppercase': RegExp(r'(?=.*[A-Z])').hasMatch(password),
      'hasLowercase': RegExp(r'(?=.*[a-z])').hasMatch(password),
      'hasNumber': RegExp(r'(?=.*\d)').hasMatch(password),
      'hasMinLength': password.length >= 8,
    };
  }
}
