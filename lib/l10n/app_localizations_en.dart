// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Athletix';

  @override
  String get appTagline => 'Your Sports Journey Starts Here';

  @override
  String get helloWorld => 'Hello World!';

  @override
  String welcomeMessage(String name) {
    return 'Welcome, $name!';
  }

  @override
  String currentDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Today\'s date is $dateString';
  }

  @override
  String get confirmButton => 'Confirm';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get deleteButton => 'Delete';

  @override
  String get okButton => 'OK';

  @override
  String get closeButton => 'Close';

  @override
  String get submitButton => 'Submit';

  @override
  String get addButton => 'Add';

  @override
  String get requiredField => 'This field is required.';

  @override
  String get notesOptionalLabel => 'Notes (optional)';

  @override
  String get notesHint => 'Add any relevant notes here...';

  @override
  String get profileTitle => 'Profile';

  @override
  String get userProfileNotFound => 'User profile not found.';

  @override
  String get notAvailableAbbreviation => 'N/A';

  @override
  String get joinedAtLabel => 'Joined At';

  @override
  String get userDataNotFound => 'User data not found';

  @override
  String get sportLabel => 'Sport';

  @override
  String get dobLabel => 'DOB';

  @override
  String get privacyTermsLink => 'Privacy Policy & Terms';

  @override
  String get privacyTermsTitle => 'Privacy & Terms';

  @override
  String get headerTagline => 'Your privacy and security matter to us';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyIntro =>
      'At Athletix, we respect your privacy. This policy applies to all users, including Athletes, Coaches, Doctors, and Organizations.';

  @override
  String get privacyBullet1 =>
      'We collect personal and professional information to enhance your experience.';

  @override
  String get privacyBullet2 =>
      'Your data is shared only with authorized individuals in your role\'s ecosystem.';

  @override
  String get privacyBullet3 => 'We do not sell your data to third parties.';

  @override
  String get privacyBullet4 =>
      'You may request deletion of your data at any time.';

  @override
  String get termsConditionsTitle => 'Terms & Conditions';

  @override
  String get termsIntro => 'By using Athletix, you agree to:';

  @override
  String get termsNumbered1 =>
      'Provide accurate registration and profile information.';

  @override
  String get termsNumbered2 => 'Use the platform respectfully and responsibly.';

  @override
  String get termsNumbered3 =>
      'Not misuse access to other users\' data or communication tools.';

  @override
  String get termsNumbered4 =>
      'Accept that Athletix is not liable for any misuse of health or performance data.';

  @override
  String get termsInfoBox =>
      'Each role (Athlete, Coach, Doctor, Organization) must adhere to guidelines specific to their access and responsibilities.';

  @override
  String get lastUpdatedLabel => 'Last Updated';

  @override
  String get lastUpdatedDate => 'January 2025';

  @override
  String contactSupport(String email) {
    return 'Questions? Contact $email';
  }

  @override
  String get supportEmail => 'support@athletix.com';

  @override
  String get welcomeBackTitle => 'Welcome Back';

  @override
  String get createAccountTitle => 'Create an Account';

  @override
  String get loginSubtitle => 'Log in to continue';

  @override
  String get signupSubtitle => 'Sign up to get started';

  @override
  String get loginButton => 'Login';

  @override
  String get signupButton => 'Signup';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get dateOfBirthLabel => 'Date of Birth';

  @override
  String get roleLabel => 'Role';

  @override
  String get specializationLabel => 'Specialization';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get roleAthlete => 'Athlete';

  @override
  String get roleCoach => 'Coach';

  @override
  String get roleDoctor => 'Doctor';

  @override
  String get userRoleNotFound => 'User role not found';

  @override
  String get notLoggedInMessage => 'Not logged in';

  @override
  String get signOutDialogTitle => 'Sign Out';

  @override
  String get signOutConfirmationMessage => 'Are you sure you want to Sign Out?';

  @override
  String get signOutButton => 'Sign Out';

  @override
  String get signOutSuccessToast => 'Signed Out successfully';

  @override
  String signOutFailedToast(String error) {
    return 'Failed to Sign out: $error';
  }

  @override
  String get sportFootball => 'Football';

  @override
  String get sportBasketball => 'Basketball';

  @override
  String get sportCricket => 'Cricket';

  @override
  String get sportTennis => 'Tennis';

  @override
  String get sportAthletics => 'Athletics';

  @override
  String get sportSwimming => 'Swimming';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalidFormat =>
      'Use a valid email (e.g., @gmail.com, @yahoo.com, @outlook.com)';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String passwordMinLength(int length) {
    return 'Password must be at least $length characters long';
  }

  @override
  String get passwordUppercase =>
      'Password must contain at least one uppercase letter';

  @override
  String get passwordLowercase =>
      'Password must contain at least one lowercase letter';

  @override
  String get passwordNumber => 'Password must contain at least one number';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String fullNameMinLength(int length) {
    return 'Name must be at least $length characters long';
  }

  @override
  String get fullNameInvalidChars => 'Name can only contain letters and spaces';

  @override
  String get dobRequired => 'Date of birth is required';

  @override
  String dobMinAge(int age) {
    return 'You must be at least $age years old';
  }

  @override
  String sportRequired(String field) {
    return '$field is required';
  }

  @override
  String get fixErrorsMessage => 'Please fix the errors';

  @override
  String checklistMinLength(int length) {
    return 'At least $length characters';
  }

  @override
  String get checklistUppercase => 'Contains uppercase letter';

  @override
  String get checklistLowercase => 'Contains lowercase letter';

  @override
  String get checklistNumber => 'Contains a number';

  @override
  String get fieldRequired => 'Required';

  @override
  String get fillAllFieldsMessage => 'Please fill all the fields!';

  @override
  String get pleaseEnterActivityDate => 'Please enter activity & date';

  @override
  String get pleaseEnterInjuryDate => 'Please enter injury & date';

  @override
  String get authErrorTitle => 'Authentication Error';

  @override
  String get authErrorEmailPassIncorrect =>
      'Email or password is incorrect. Please try again.';

  @override
  String get authErrorInvalidEmail => 'The email address is not valid.';

  @override
  String get authErrorUserDisabled => 'This user account has been disabled.';

  @override
  String get authErrorEmailInUse =>
      'This email is already registered. Try logging in.';

  @override
  String get authErrorWeakPassword =>
      'Your password must be at least 8 characters and contain a number.';

  @override
  String get authErrorOperationNotAllowed =>
      'This operation is not allowed. Please contact support.';

  @override
  String get authErrorUnknown => 'An unknown error occurred. Please try again.';

  @override
  String get logoutTooltip => 'Logout';

  @override
  String get quickActionsTitle => 'Quick Actions';

  @override
  String get navBarHome => 'Home';

  @override
  String get navBarPlayers => 'Players';

  @override
  String get navBarTournaments => 'Tournaments';

  @override
  String get navBarProfile => 'Profile';

  @override
  String get navBarCalendar => 'Calendar';

  @override
  String get doctorDashboardTitle => 'Doctor Dashboard';

  @override
  String get welcomeDoctorMessage => 'Welcome, Doctor!';

  @override
  String get coachDashboardTitle => 'Coach Dashboard';

  @override
  String get welcomeCoachMessage => 'Welcome, Coach!';

  @override
  String get athleteDashboardTitle => 'Dashboard';

  @override
  String get injuryTrackerLabel => 'Injury Tracker';

  @override
  String get performanceLogsLabel => 'Performance Logs';

  @override
  String get financialTrackerLabel => 'Financial Tracker';

  @override
  String get homeLabel => 'Home';

  @override
  String get playersLabel => 'Players';

  @override
  String get tournamentsLabel => 'Tournaments';

  @override
  String get profileLabel => 'Profile';

  @override
  String get timeTableLabel => 'Time Table';

  @override
  String get addTournamentTitle => 'Add Tournament';

  @override
  String get tournamentNameLabel => 'Tournament Name';

  @override
  String get levelLabel => 'Level';

  @override
  String get levelDistrict => 'District';

  @override
  String get levelState => 'State';

  @override
  String get levelNational => 'National';

  @override
  String get levelInternational => 'International';

  @override
  String get pickDateButton => 'Pick Date';

  @override
  String get pickTimeButton => 'Pick Time';

  @override
  String get pickLocationButton => 'Pick Location';

  @override
  String get locationPicked => 'Location picked';

  @override
  String get saveTournamentButton => 'Save Tournament';

  @override
  String get locationPermissionDenied => 'Location permission denied.';

  @override
  String get locationPermissionDeniedForever =>
      'Location permissions are permanently denied, please enable them in settings.';

  @override
  String get tournamentAddSuccessTitle => 'Success';

  @override
  String get tournamentAddSuccessContent => 'Tournament added successfully!';

  @override
  String get pickLocationMapTitle => 'Pick Location';

  @override
  String get managePlayersTitle => 'Manage Players';

  @override
  String get managePlayersScreenContent => 'Manage Players Screen';

  @override
  String get organizationDashboardTitle => 'Organization Dashboard';

  @override
  String get tournamentsTitle => 'Tournaments';

  @override
  String get locationServicesDisabled => 'Location services are disabled.';

  @override
  String errorFetchingTournaments(String error) {
    return 'Error: $error';
  }

  @override
  String get noTournamentsFound => 'No tournaments found.';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get addressLabel => 'Address';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get addActivityTitle => 'Add Activity';

  @override
  String get workActivityLabel => 'Work/Activity';

  @override
  String get selectStartTimeButton => 'Select Start Time';

  @override
  String get startTimePrefix => 'Start';

  @override
  String get selectEndTimeButton => 'Select End Time';

  @override
  String get endTimePrefix => 'End';

  @override
  String get noActivitiesToday => 'No upcoming activities for this day.';

  @override
  String get addActivityFabTooltip => 'Add New Activity';

  @override
  String get performanceLogsTitle => 'Performance Logs';

  @override
  String get addLogFabLabel => 'Add Log';

  @override
  String get addLogFabTooltip => 'Add new performance log';

  @override
  String get addPerformanceLogTitle => 'Add Performance Log';

  @override
  String get activityLabel => 'Activity *';

  @override
  String get activityHint => 'What did you do?';

  @override
  String get deleteLogTitle => 'Delete Log';

  @override
  String get deleteLogConfirmation =>
      'Are you sure you want to delete this performance log entry?';

  @override
  String get noPerformanceLogsYet => 'No performance logs yet.';

  @override
  String get logCardDatePrefix => 'Date';

  @override
  String get logCardNotesPrefix => 'Notes';

  @override
  String get deleteEntryTooltip => 'Delete entry';

  @override
  String get injuryTrackerTitle => 'Injury Tracker';

  @override
  String get addInjuryFabLabel => 'Add Injury';

  @override
  String get addInjurySheetTitle => 'Add Injury';

  @override
  String get injuryDescriptionLabel => 'Injury Description *';

  @override
  String get injuryDescriptionHint => 'Describe your injury';

  @override
  String get injuryDateLabel => 'Injury Date *';

  @override
  String get deleteInjuryTitle => 'Delete Injury';

  @override
  String get deleteInjuryConfirmation =>
      'Are you sure you want to delete this injury entry?';

  @override
  String get noInjuriesLoggedYet => 'No injuries logged yet.';

  @override
  String get deleteInjuryTooltip => 'Delete Injury';

  @override
  String get injuryCardDatePrefix => 'Date';

  @override
  String get injuryCardNotesPrefix => 'Notes';

  @override
  String get financialTrackerTitle => 'Financial Tracker';

  @override
  String get viewGraphTooltip => 'View Graph';

  @override
  String get closeFormTooltip => 'Close Form';

  @override
  String get addEntryTooltip => 'Add New Entry';

  @override
  String get incomeType => 'Income';

  @override
  String get expenseType => 'Expense';

  @override
  String get categoryLabel => 'Category';

  @override
  String get amountLabel => 'Amount';

  @override
  String get updateEntryButton => 'Update Entry';

  @override
  String get addEntryButton => 'Add Entry';

  @override
  String get selectDateRangeTooltip => 'Select Date Range';

  @override
  String get filterCategoryHint => 'Filter by category...';

  @override
  String get clearFiltersTooltip => 'Clear Filters';

  @override
  String get viewTypeMonthly => 'Monthly';

  @override
  String get viewTypeWeekly => 'Weekly';

  @override
  String get viewTypeDaily => 'Daily';

  @override
  String get viewTypeYearly => 'Yearly';

  @override
  String get incomeSummary => 'Income';

  @override
  String get expenseSummary => 'Expense';

  @override
  String get balanceSummary => 'Balance';

  @override
  String get transactionsHeading => 'Transactions';

  @override
  String get deleteTransactionDialogTitle => 'Confirm Deletion';

  @override
  String get deleteTransactionConfirmation =>
      'Are you sure you want to delete this financial entry?';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get noDataAvailable => 'No data available.';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categoryBonus => 'Bonus';

  @override
  String get categoryFreelance => 'Freelance';

  @override
  String get categoryInvestmentsIncome => 'Investments';

  @override
  String get categoryGifts => 'Gifts';

  @override
  String get categoryRentIncome => 'Rent Income';

  @override
  String get categoryOtherIncome => 'Other Income';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTransportation => 'Transportation';

  @override
  String get categoryHousing => 'Housing';

  @override
  String get categoryUtilities => 'Utilities';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryDiningOut => 'Dining Out';

  @override
  String get categoryLoans => 'Loans';

  @override
  String get categoryInsurance => 'Insurance';

  @override
  String get categorySavings => 'Savings';

  @override
  String get categoryInvestmentsExpense => 'Investments';

  @override
  String get categoryOtherExpenses => 'Other Expenses';

  @override
  String get incomeExpensesChartTitle => 'Income & Expenses';

  @override
  String get currencySymbol => '₹';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get weekPrefix => 'W';

  @override
  String get loadingDashboard => 'Loading your dashboard...';

  @override
  String get refreshPrompt => 'Please try refreshing the page';

  @override
  String get refreshButton => 'Refresh';

  @override
  String get greetingMorning => 'Good Morning';

  @override
  String get greetingAfternoon => 'Good Afternoon';

  @override
  String get greetingEvening => 'Good Evening';

  @override
  String get notSetLabel => 'Not set';

  @override
  String get monitorHealthSubtitle => 'Monitor your health';

  @override
  String get performanceLabel => 'Performance';

  @override
  String get trackProgressSubtitle => 'Track your progress';

  @override
  String get financesLabel => 'Finances';

  @override
  String get manageExpensesSubtitle => 'Manage expenses';

  @override
  String get thisWeekTitle => 'This Week';

  @override
  String get trainingSessionsTitle => 'Training Sessions';

  @override
  String get hoursTrainedTitle => 'Hours Trained';

  @override
  String get errorPrefix => 'Error';

  @override
  String get tournamentLevelLabel => 'Level';

  @override
  String get newUserPrompt => 'New user?';

  @override
  String get alreadyHaveAccountPrompt => 'Already have an account?';

  @override
  String get viewTournamentsLabel => 'View Tournaments';

  @override
  String get dismissButton => 'Dismiss';

  @override
  String get emailVerificationRequiredTitle => 'Email Verification Required';

  @override
  String emailVerificationInstructionMessage(Object email) {
    return 'We\'ve sent a verification email to\n$email';
  }

  @override
  String get checkInboxSpamMessage =>
      'Please check your inbox and spam folder, then click the verification link. Once verified, click \"I\'ve Verified\" to continue.';

  @override
  String get sendingButton => 'Sending...';

  @override
  String get resendEmailButton => 'Resend Email';

  @override
  String get checkingButton => 'Checking...';

  @override
  String get iveVerifiedButton => 'I\'ve Verified';

  @override
  String get goBackButton => 'Go Back';

  @override
  String get welcomeGreeting => 'Welcome Back,';

  @override
  String doctorName(Object name) {
    return 'Dr. $name';
  }

  @override
  String get profileInfoTitle => 'Profile Information';

  @override
  String get yourProfessionalDetails => 'Your professional details';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get accessToolsSubtitle =>
      'Access your tools and manage your practice';

  @override
  String get qualificationsAndLicense => 'Qualifications & License';

  @override
  String get announcements => 'Announcements';

  @override
  String get informationCenter => 'Information Center';

  @override
  String get filterActivityHint => 'Filter activity';

  @override
  String logsFilteredBy(Object dateFilter, Object activityFilter) {
    return 'Showing logs for $dateFilter | Filtered by: $activityFilter';
  }

  @override
  String get allDatesLabel => 'all dates';

  @override
  String get allActivitiesLabel => 'all activities';
}
