import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Athletix'**
  String get appName;

  /// A tagline for the application on the splash screen
  ///
  /// In en, this message translates to:
  /// **'Your Sports Journey Starts Here'**
  String get appTagline;

  /// A classic welcome message
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// Welcome message with a placeholder for a name
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcomeMessage(String name);

  /// Shows the current date
  ///
  /// In en, this message translates to:
  /// **'Today\'s date is {date}'**
  String currentDate(DateTime date);

  /// Text for a general confirmation button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// Text for a general cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Text for general save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// Text for the delete button in a dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// Text for general OK button in dialogs
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// Text for the close button in dialogs
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// Text for the submit button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// Text for the add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// Generic validation message for a required field
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredField;

  /// Label for the notes text field
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptionalLabel;

  /// Hint text for the notes text field
  ///
  /// In en, this message translates to:
  /// **'Add any relevant notes here...'**
  String get notesHint;

  /// Title for the profile screen
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Message displayed when user profile data is not found
  ///
  /// In en, this message translates to:
  /// **'User profile not found.'**
  String get userProfileNotFound;

  /// Abbreviation for not available
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailableAbbreviation;

  /// Label for user joined date
  ///
  /// In en, this message translates to:
  /// **'Joined At'**
  String get joinedAtLabel;

  /// Message shown when user data cannot be found on the dashboard
  ///
  /// In en, this message translates to:
  /// **'User data not found'**
  String get userDataNotFound;

  /// Label for displaying sport in user card
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get sportLabel;

  /// Label for Date of Birth in user card
  ///
  /// In en, this message translates to:
  /// **'DOB'**
  String get dobLabel;

  /// Text for the privacy policy and terms link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy & Terms'**
  String get privacyTermsLink;

  /// App bar title for the Privacy & Terms page
  ///
  /// In en, this message translates to:
  /// **'Privacy & Terms'**
  String get privacyTermsTitle;

  /// Tagline on the header card of Privacy & Terms page
  ///
  /// In en, this message translates to:
  /// **'Your privacy and security matter to us'**
  String get headerTagline;

  /// Title for the Privacy Policy section
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// Introductory text for the privacy policy
  ///
  /// In en, this message translates to:
  /// **'At Athletix, we respect your privacy. This policy applies to all users, including Athletes, Coaches, Doctors, and Organizations.'**
  String get privacyPolicyIntro;

  /// Bullet point 1 of privacy policy
  ///
  /// In en, this message translates to:
  /// **'We collect personal and professional information to enhance your experience.'**
  String get privacyBullet1;

  /// Bullet point 2 of privacy policy
  ///
  /// In en, this message translates to:
  /// **'Your data is shared only with authorized individuals in your role\'s ecosystem.'**
  String get privacyBullet2;

  /// Bullet point 3 of privacy policy
  ///
  /// In en, this message translates to:
  /// **'We do not sell your data to third parties.'**
  String get privacyBullet3;

  /// Bullet point 4 of privacy policy
  ///
  /// In en, this message translates to:
  /// **'You may request deletion of your data at any time.'**
  String get privacyBullet4;

  /// Title for the Terms & Conditions section
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditionsTitle;

  /// Introductory text for terms and conditions
  ///
  /// In en, this message translates to:
  /// **'By using Athletix, you agree to:'**
  String get termsIntro;

  /// Numbered point 1 of terms and conditions
  ///
  /// In en, this message translates to:
  /// **'Provide accurate registration and profile information.'**
  String get termsNumbered1;

  /// Numbered point 2 of terms and conditions
  ///
  /// In en, this message translates to:
  /// **'Use the platform respectfully and responsibly.'**
  String get termsNumbered2;

  /// Numbered point 3 of terms and conditions
  ///
  /// In en, this message translates to:
  /// **'Not misuse access to other users\' data or communication tools.'**
  String get termsNumbered3;

  /// Numbered point 4 of terms and conditions
  ///
  /// In en, this message translates to:
  /// **'Accept that Athletix is not liable for any misuse of health or performance data.'**
  String get termsNumbered4;

  /// Information box text in terms and conditions
  ///
  /// In en, this message translates to:
  /// **'Each role (Athlete, Coach, Doctor, Organization) must adhere to guidelines specific to their access and responsibilities.'**
  String get termsInfoBox;

  /// Label for the last updated date in the footer
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdatedLabel;

  /// The actual last updated date
  ///
  /// In en, this message translates to:
  /// **'January 2025'**
  String get lastUpdatedDate;

  /// Contact support text in the footer
  ///
  /// In en, this message translates to:
  /// **'Questions? Contact {email}'**
  String contactSupport(String email);

  /// The support email address
  ///
  /// In en, this message translates to:
  /// **'support@athletix.com'**
  String get supportEmail;

  /// Title for the login page
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBackTitle;

  /// Title for the signup page
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAccountTitle;

  /// Subtitle for the login page
  ///
  /// In en, this message translates to:
  /// **'Log in to continue'**
  String get loginSubtitle;

  /// Subtitle for the signup page
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get signupSubtitle;

  /// Text for the Login button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// Text for the Signup button
  ///
  /// In en, this message translates to:
  /// **'Signup'**
  String get signupButton;

  /// Label for the full name text field
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// Label for the date of birth text field
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirthLabel;

  /// Label for the role dropdown
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// Label for the specialization text field (for doctors)
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specializationLabel;

  /// Label for the email text field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Label for the password text field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @roleAthlete.
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get roleAthlete;

  /// No description provided for @roleCoach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get roleCoach;

  /// No description provided for @roleDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get roleDoctor;

  /// No description provided for @userRoleNotFound.
  ///
  /// In en, this message translates to:
  /// **'User role not found'**
  String get userRoleNotFound;

  /// Message shown when user is not logged in
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedInMessage;

  /// Title for the sign out confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutDialogTitle;

  /// Content message for the sign out confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to Sign Out?'**
  String get signOutConfirmationMessage;

  /// Text for the sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutButton;

  /// Toast message shown on successful sign out
  ///
  /// In en, this message translates to:
  /// **'Signed Out successfully'**
  String get signOutSuccessToast;

  /// Toast message shown when sign out fails
  ///
  /// In en, this message translates to:
  /// **'Failed to Sign out: {error}'**
  String signOutFailedToast(String error);

  /// No description provided for @sportFootball.
  ///
  /// In en, this message translates to:
  /// **'Football'**
  String get sportFootball;

  /// No description provided for @sportBasketball.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get sportBasketball;

  /// No description provided for @sportCricket.
  ///
  /// In en, this message translates to:
  /// **'Cricket'**
  String get sportCricket;

  /// No description provided for @sportTennis.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get sportTennis;

  /// No description provided for @sportAthletics.
  ///
  /// In en, this message translates to:
  /// **'Athletics'**
  String get sportAthletics;

  /// No description provided for @sportSwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get sportSwimming;

  /// Validation error: email is empty
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// Validation error: email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Use a valid email (e.g., @gmail.com, @yahoo.com, @outlook.com)'**
  String get emailInvalidFormat;

  /// Validation error: password is empty
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Validation error: password too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {length} characters long'**
  String passwordMinLength(int length);

  /// Validation error: missing uppercase
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get passwordUppercase;

  /// Validation error: missing lowercase
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one lowercase letter'**
  String get passwordLowercase;

  /// Validation error: missing number
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get passwordNumber;

  /// Validation error: full name is empty
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// Validation error: name too short
  ///
  /// In en, this message translates to:
  /// **'Name must be at least {length} characters long'**
  String fullNameMinLength(int length);

  /// Validation error: name contains invalid characters
  ///
  /// In en, this message translates to:
  /// **'Name can only contain letters and spaces'**
  String get fullNameInvalidChars;

  /// Validation error: date of birth is empty
  ///
  /// In en, this message translates to:
  /// **'Date of birth is required'**
  String get dobRequired;

  /// Validation error: user is too young
  ///
  /// In en, this message translates to:
  /// **'You must be at least {age} years old'**
  String dobMinAge(int age);

  /// Validation error: sport or specialization is empty
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String sportRequired(String field);

  /// Generic message for validation errors
  ///
  /// In en, this message translates to:
  /// **'Please fix the errors'**
  String get fixErrorsMessage;

  /// Password checklist item: min length
  ///
  /// In en, this message translates to:
  /// **'At least {length} characters'**
  String checklistMinLength(int length);

  /// Password checklist item: uppercase
  ///
  /// In en, this message translates to:
  /// **'Contains uppercase letter'**
  String get checklistUppercase;

  /// Password checklist item: lowercase
  ///
  /// In en, this message translates to:
  /// **'Contains lowercase letter'**
  String get checklistLowercase;

  /// Password checklist item: number
  ///
  /// In en, this message translates to:
  /// **'Contains a number'**
  String get checklistNumber;

  /// Generic validation message for a required field
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// Message shown when not all fields are filled in the tournament form
  ///
  /// In en, this message translates to:
  /// **'Please fill all the fields!'**
  String get fillAllFieldsMessage;

  /// Validation message for activity and date fields
  ///
  /// In en, this message translates to:
  /// **'Please enter activity & date'**
  String get pleaseEnterActivityDate;

  /// Validation message for injury and date fields
  ///
  /// In en, this message translates to:
  /// **'Please enter injury & date'**
  String get pleaseEnterInjuryDate;

  /// Title for authentication error dialog
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get authErrorTitle;

  /// Firebase auth error: user-not-found, wrong-password
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect. Please try again.'**
  String get authErrorEmailPassIncorrect;

  /// Firebase auth error: invalid-email
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid.'**
  String get authErrorInvalidEmail;

  /// Firebase auth error: user-disabled
  ///
  /// In en, this message translates to:
  /// **'This user account has been disabled.'**
  String get authErrorUserDisabled;

  /// Firebase auth error: email-already-in-use
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Try logging in.'**
  String get authErrorEmailInUse;

  /// Firebase auth error: weak-password
  ///
  /// In en, this message translates to:
  /// **'Your password must be at least 8 characters and contain a number.'**
  String get authErrorWeakPassword;

  /// Firebase auth error: operation-not-allowed
  ///
  /// In en, this message translates to:
  /// **'This operation is not allowed. Please contact support.'**
  String get authErrorOperationNotAllowed;

  /// Generic unknown Firebase auth error
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred. Please try again.'**
  String get authErrorUnknown;

  /// Tooltip text for the logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTooltip;

  /// Title for the quick actions section on the dashboard
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActionsTitle;

  /// Label for Home tab in bottom navigation bar
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navBarHome;

  /// Label for Players tab in bottom navigation bar
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get navBarPlayers;

  /// Label for Tournaments tab in bottom navigation bar
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get navBarTournaments;

  /// Label for Profile tab in bottom navigation bar
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navBarProfile;

  /// Label for Calendar tab in bottom navigation bar
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navBarCalendar;

  /// App bar title for the Doctor Dashboard screen
  ///
  /// In en, this message translates to:
  /// **'Doctor Dashboard'**
  String get doctorDashboardTitle;

  /// Welcome message for the Doctor Dashboard
  ///
  /// In en, this message translates to:
  /// **'Welcome, Doctor!'**
  String get welcomeDoctorMessage;

  /// App bar title for the Coach Dashboard screen
  ///
  /// In en, this message translates to:
  /// **'Coach Dashboard'**
  String get coachDashboardTitle;

  /// Welcome message for the Coach Dashboard
  ///
  /// In en, this message translates to:
  /// **'Welcome, Coach!'**
  String get welcomeCoachMessage;

  /// App bar title for the Athlete Dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get athleteDashboardTitle;

  /// Label for the Injury Tracker quick action card
  ///
  /// In en, this message translates to:
  /// **'Injury Tracker'**
  String get injuryTrackerLabel;

  /// Label for the Performance Logs quick action card
  ///
  /// In en, this message translates to:
  /// **'Performance Logs'**
  String get performanceLogsLabel;

  /// Label for the Financial Tracker quick action card
  ///
  /// In en, this message translates to:
  /// **'Financial Tracker'**
  String get financialTrackerLabel;

  /// Label for the Home navigation item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLabel;

  /// Label for the Players navigation item (Organization role)
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get playersLabel;

  /// Label for the Tournaments navigation item
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get tournamentsLabel;

  /// Label for the Profile navigation item
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileLabel;

  /// Label for the Time Table navigation item (Player role)
  ///
  /// In en, this message translates to:
  /// **'Time Table'**
  String get timeTableLabel;

  /// App bar title for Add Tournament screen
  ///
  /// In en, this message translates to:
  /// **'Add Tournament'**
  String get addTournamentTitle;

  /// Label for tournament name text field
  ///
  /// In en, this message translates to:
  /// **'Tournament Name'**
  String get tournamentNameLabel;

  /// Label for tournament level dropdown
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelLabel;

  /// No description provided for @levelDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get levelDistrict;

  /// No description provided for @levelState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get levelState;

  /// No description provided for @levelNational.
  ///
  /// In en, this message translates to:
  /// **'National'**
  String get levelNational;

  /// No description provided for @levelInternational.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get levelInternational;

  /// Text for pick date button
  ///
  /// In en, this message translates to:
  /// **'Pick Date'**
  String get pickDateButton;

  /// Text for pick time button
  ///
  /// In en, this message translates to:
  /// **'Pick Time'**
  String get pickTimeButton;

  /// Text for pick location button
  ///
  /// In en, this message translates to:
  /// **'Pick Location'**
  String get pickLocationButton;

  /// Text shown when a location has been picked
  ///
  /// In en, this message translates to:
  /// **'Location picked'**
  String get locationPicked;

  /// Text for save tournament button
  ///
  /// In en, this message translates to:
  /// **'Save Tournament'**
  String get saveTournamentButton;

  /// Error message when location permission is denied
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get locationPermissionDenied;

  /// Error message when location permission is permanently denied
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied, please enable them in settings.'**
  String get locationPermissionDeniedForever;

  /// Title for tournament added successfully dialog
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get tournamentAddSuccessTitle;

  /// Content for tournament added successfully dialog
  ///
  /// In en, this message translates to:
  /// **'Tournament added successfully!'**
  String get tournamentAddSuccessContent;

  /// App bar title for the Map Screen
  ///
  /// In en, this message translates to:
  /// **'Pick Location'**
  String get pickLocationMapTitle;

  /// App bar title for the Manage Players screen
  ///
  /// In en, this message translates to:
  /// **'Manage Players'**
  String get managePlayersTitle;

  /// Content text for the Manage Players screen
  ///
  /// In en, this message translates to:
  /// **'Manage Players Screen'**
  String get managePlayersScreenContent;

  /// App bar title for the Organization Dashboard
  ///
  /// In en, this message translates to:
  /// **'Organization Dashboard'**
  String get organizationDashboardTitle;

  /// App bar title for the Tournaments screen
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get tournamentsTitle;

  /// Error message when location services are disabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get locationServicesDisabled;

  /// Generic error message when fetching tournaments fails
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorFetchingTournaments(String error);

  /// Message displayed when no tournaments match the criteria.
  ///
  /// In en, this message translates to:
  /// **'No tournaments found.'**
  String get noTournamentsFound;

  /// Label for tournament date in details dialog
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// Label for tournament time in details dialog
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// Label for tournament address in details dialog
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// App bar title for the Calendar screen
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// Title for the 'Add Activity' dialog
  ///
  /// In en, this message translates to:
  /// **'Add Activity'**
  String get addActivityTitle;

  /// Label for the work/activity text field
  ///
  /// In en, this message translates to:
  /// **'Work/Activity'**
  String get workActivityLabel;

  /// Text for the 'Select Start Time' button
  ///
  /// In en, this message translates to:
  /// **'Select Start Time'**
  String get selectStartTimeButton;

  /// Prefix for displaying selected start time
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startTimePrefix;

  /// Text for the 'Select End Time' button
  ///
  /// In en, this message translates to:
  /// **'Select End Time'**
  String get selectEndTimeButton;

  /// Prefix for displaying selected end time
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endTimePrefix;

  /// Message shown when no activities are scheduled for the selected day
  ///
  /// In en, this message translates to:
  /// **'No upcoming activities for this day.'**
  String get noActivitiesToday;

  /// Tooltip for the floating action button to add an activity
  ///
  /// In en, this message translates to:
  /// **'Add New Activity'**
  String get addActivityFabTooltip;

  /// App bar title for the Performance Logs screen
  ///
  /// In en, this message translates to:
  /// **'Performance Logs'**
  String get performanceLogsTitle;

  /// Label for the Floating Action Button to add a log
  ///
  /// In en, this message translates to:
  /// **'Add Log'**
  String get addLogFabLabel;

  /// Tooltip for the Floating Action Button to add a log
  ///
  /// In en, this message translates to:
  /// **'Add new performance log'**
  String get addLogFabTooltip;

  /// Title for the 'Add Performance Log' bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Add Performance Log'**
  String get addPerformanceLogTitle;

  /// Label for the activity text field
  ///
  /// In en, this message translates to:
  /// **'Activity *'**
  String get activityLabel;

  /// Hint text for the activity text field
  ///
  /// In en, this message translates to:
  /// **'What did you do?'**
  String get activityHint;

  /// Title for the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Log'**
  String get deleteLogTitle;

  /// Content message for the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this performance log entry?'**
  String get deleteLogConfirmation;

  /// Message shown when there are no performance logs
  ///
  /// In en, this message translates to:
  /// **'No performance logs yet.'**
  String get noPerformanceLogsYet;

  /// Prefix for date in performance log card
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get logCardDatePrefix;

  /// Prefix for notes in performance log card
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get logCardNotesPrefix;

  /// Tooltip for the delete icon button on a log entry
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get deleteEntryTooltip;

  /// App bar title for the Injury Tracker screen
  ///
  /// In en, this message translates to:
  /// **'Injury Tracker'**
  String get injuryTrackerTitle;

  /// Label for the Floating Action Button to add an injury
  ///
  /// In en, this message translates to:
  /// **'Add Injury'**
  String get addInjuryFabLabel;

  /// Title for the 'Add Injury' bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Add Injury'**
  String get addInjurySheetTitle;

  /// Label for the injury description text field
  ///
  /// In en, this message translates to:
  /// **'Injury Description *'**
  String get injuryDescriptionLabel;

  /// Hint text for the injury description text field
  ///
  /// In en, this message translates to:
  /// **'Describe your injury'**
  String get injuryDescriptionHint;

  /// Label for the injury date text field
  ///
  /// In en, this message translates to:
  /// **'Injury Date *'**
  String get injuryDateLabel;

  /// Title for the delete injury confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Injury'**
  String get deleteInjuryTitle;

  /// Content message for the delete injury confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this injury entry?'**
  String get deleteInjuryConfirmation;

  /// Message shown when there are no injury logs
  ///
  /// In en, this message translates to:
  /// **'No injuries logged yet.'**
  String get noInjuriesLoggedYet;

  /// Tooltip for the delete icon button on an injury entry
  ///
  /// In en, this message translates to:
  /// **'Delete Injury'**
  String get deleteInjuryTooltip;

  /// No description provided for @injuryCardDatePrefix.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get injuryCardDatePrefix;

  /// No description provided for @injuryCardNotesPrefix.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get injuryCardNotesPrefix;

  /// App bar title for the Financial Tracker screen
  ///
  /// In en, this message translates to:
  /// **'Financial Tracker'**
  String get financialTrackerTitle;

  /// Tooltip for the Floating Action Button to view the financial graph
  ///
  /// In en, this message translates to:
  /// **'View Graph'**
  String get viewGraphTooltip;

  /// Tooltip for the Floating Action Button to close the entry form
  ///
  /// In en, this message translates to:
  /// **'Close Form'**
  String get closeFormTooltip;

  /// Tooltip for the Floating Action Button to open the entry form or add a new entry
  ///
  /// In en, this message translates to:
  /// **'Add New Entry'**
  String get addEntryTooltip;

  /// Label for income type dropdown option
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeType;

  /// Label for expense type dropdown option
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseType;

  /// Label for financial entry category dropdown
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// Label for financial entry amount text field
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// Text for the button to update a financial entry
  ///
  /// In en, this message translates to:
  /// **'Update Entry'**
  String get updateEntryButton;

  /// Text for the button to add a new financial entry
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get addEntryButton;

  /// Tooltip for the date range filter icon
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRangeTooltip;

  /// Hint text for the category filter text field
  ///
  /// In en, this message translates to:
  /// **'Filter by category...'**
  String get filterCategoryHint;

  /// Tooltip for the clear filters button
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFiltersTooltip;

  /// Label for monthly view type chip
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get viewTypeMonthly;

  /// Label for weekly view type chip
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get viewTypeWeekly;

  /// Label for daily view type chip
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get viewTypeDaily;

  /// Label for yearly view type chip in financial chart
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get viewTypeYearly;

  /// Label for total income in summary section
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeSummary;

  /// Label for total expense in summary section
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseSummary;

  /// Label for total balance in summary section
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceSummary;

  /// Heading for the list of financial transactions
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsHeading;

  /// Title for the delete transaction confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get deleteTransactionDialogTitle;

  /// Content message for the delete transaction confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this financial entry?'**
  String get deleteTransactionConfirmation;

  /// Message shown while data is loading
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// Message shown when no financial data is found
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get noDataAvailable;

  /// No description provided for @categorySalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get categorySalary;

  /// No description provided for @categoryBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get categoryBonus;

  /// No description provided for @categoryFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get categoryFreelance;

  /// No description provided for @categoryInvestmentsIncome.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get categoryInvestmentsIncome;

  /// No description provided for @categoryGifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get categoryGifts;

  /// No description provided for @categoryRentIncome.
  ///
  /// In en, this message translates to:
  /// **'Rent Income'**
  String get categoryRentIncome;

  /// No description provided for @categoryOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other Income'**
  String get categoryOtherIncome;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryTransportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get categoryTransportation;

  /// No description provided for @categoryHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get categoryHousing;

  /// No description provided for @categoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get categoryUtilities;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get categoryGroceries;

  /// No description provided for @categoryDiningOut.
  ///
  /// In en, this message translates to:
  /// **'Dining Out'**
  String get categoryDiningOut;

  /// No description provided for @categoryLoans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get categoryLoans;

  /// No description provided for @categoryInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get categoryInsurance;

  /// No description provided for @categorySavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get categorySavings;

  /// No description provided for @categoryInvestmentsExpense.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get categoryInvestmentsExpense;

  /// No description provided for @categoryOtherExpenses.
  ///
  /// In en, this message translates to:
  /// **'Other Expenses'**
  String get categoryOtherExpenses;

  /// Title for the income and expenses bar chart
  ///
  /// In en, this message translates to:
  /// **'Income & Expenses'**
  String get incomeExpensesChartTitle;

  /// The currency symbol used in financial displays
  ///
  /// In en, this message translates to:
  /// **'₹'**
  String get currencySymbol;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// Prefix for week numbers, e.g., W1, W2
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekPrefix;

  /// No description provided for @loadingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Loading your dashboard...'**
  String get loadingDashboard;

  /// No description provided for @refreshPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please try refreshing the page'**
  String get refreshPrompt;

  /// No description provided for @refreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshButton;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get greetingEvening;

  /// No description provided for @notSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSetLabel;

  /// No description provided for @monitorHealthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor your health'**
  String get monitorHealthSubtitle;

  /// No description provided for @performanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performanceLabel;

  /// No description provided for @trackProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get trackProgressSubtitle;

  /// No description provided for @financesLabel.
  ///
  /// In en, this message translates to:
  /// **'Finances'**
  String get financesLabel;

  /// No description provided for @manageExpensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage expenses'**
  String get manageExpensesSubtitle;

  /// No description provided for @thisWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeekTitle;

  /// No description provided for @trainingSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Sessions'**
  String get trainingSessionsTitle;

  /// No description provided for @hoursTrainedTitle.
  ///
  /// In en, this message translates to:
  /// **'Hours Trained'**
  String get hoursTrainedTitle;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorPrefix;

  /// No description provided for @tournamentLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get tournamentLevelLabel;

  /// No description provided for @newUserPrompt.
  ///
  /// In en, this message translates to:
  /// **'New user?'**
  String get newUserPrompt;

  /// No description provided for @alreadyHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountPrompt;

  /// No description provided for @viewTournamentsLabel.
  ///
  /// In en, this message translates to:
  /// **'View Tournaments'**
  String get viewTournamentsLabel;

  /// No description provided for @dismissButton.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissButton;

  /// No description provided for @emailVerificationRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Verification Required'**
  String get emailVerificationRequiredTitle;

  /// No description provided for @emailVerificationInstructionMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification email to\n{email}'**
  String emailVerificationInstructionMessage(Object email);

  /// No description provided for @checkInboxSpamMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox and spam folder, then click the verification link. Once verified, click \"I\'ve Verified\" to continue.'**
  String get checkInboxSpamMessage;

  /// No description provided for @sendingButton.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sendingButton;

  /// No description provided for @resendEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get resendEmailButton;

  /// No description provided for @checkingButton.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checkingButton;

  /// No description provided for @iveVerifiedButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Verified'**
  String get iveVerifiedButton;

  /// No description provided for @goBackButton.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBackButton;

  /// No description provided for @welcomeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back,'**
  String get welcomeGreeting;

  /// No description provided for @doctorName.
  ///
  /// In en, this message translates to:
  /// **'Dr. {name}'**
  String doctorName(Object name);

  /// No description provided for @profileInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInfoTitle;

  /// No description provided for @yourProfessionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Your professional details'**
  String get yourProfessionalDetails;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @accessToolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your tools and manage your practice'**
  String get accessToolsSubtitle;

  /// No description provided for @qualificationsAndLicense.
  ///
  /// In en, this message translates to:
  /// **'Qualifications & License'**
  String get qualificationsAndLicense;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @informationCenter.
  ///
  /// In en, this message translates to:
  /// **'Information Center'**
  String get informationCenter;

  /// No description provided for @filterActivityHint.
  ///
  /// In en, this message translates to:
  /// **'Filter activity'**
  String get filterActivityHint;

  /// No description provided for @logsFilteredBy.
  ///
  /// In en, this message translates to:
  /// **'Showing logs for {dateFilter} | Filtered by: {activityFilter}'**
  String logsFilteredBy(Object dateFilter, Object activityFilter);

  /// No description provided for @allDatesLabel.
  ///
  /// In en, this message translates to:
  /// **'all dates'**
  String get allDatesLabel;

  /// No description provided for @allActivitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'all activities'**
  String get allActivitiesLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
