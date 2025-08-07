class FormValidation {
  final Map<String, bool> tappedFields;
  final Map<String, String?> fieldErrors;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasMinLength;

  FormValidation({
    required this.tappedFields,
    required this.fieldErrors,
    this.hasUppercase = false,
    this.hasLowercase = false,
    this.hasNumber = false,
    this.hasMinLength = false,
  });

  FormValidation copyWith({
    Map<String, bool>? tappedFields,
    Map<String, String?>? fieldErrors,
    bool? hasUppercase,
    bool? hasLowercase,
    bool? hasNumber,
    bool? hasMinLength,
  }) {
    return FormValidation(
      tappedFields: tappedFields ?? this.tappedFields,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      hasUppercase: hasUppercase ?? this.hasUppercase,
      hasLowercase: hasLowercase ?? this.hasLowercase,
      hasNumber: hasNumber ?? this.hasNumber,
      hasMinLength: hasMinLength ?? this.hasMinLength,
    );
  }

  static FormValidation initial() {
    return FormValidation(
      tappedFields: {
        'email': false,
        'password': false,
        'name': false,
        'sport': false,
        'dob': false,
      },
      fieldErrors: {
        'email': null,
        'password': null,
        'name': null,
        'sport': null,
        'dob': null,
      },
    );
  }
}
