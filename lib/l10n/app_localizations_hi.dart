// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'एथलेटिक्स';

  @override
  String get appTagline => 'आपकी खेल यात्रा यहीं से शुरू होती है';

  @override
  String get helloWorld => 'नमस्ते दुनिया!';

  @override
  String welcomeMessage(String name) {
    return 'स्वागत है, $name!';
  }

  @override
  String currentDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'आज की तारीख है $dateString';
  }

  @override
  String get confirmButton => 'पुष्टि करें';

  @override
  String get cancelButton => 'रद्द करें';

  @override
  String get saveButton => 'सहेजें';

  @override
  String get deleteButton => 'हटाएँ';

  @override
  String get okButton => 'ठीक है';

  @override
  String get closeButton => 'बंद करें';

  @override
  String get submitButton => 'जमा करें';

  @override
  String get addButton => 'जोड़ें';

  @override
  String get requiredField => 'आवश्यक';

  @override
  String get notesOptionalLabel => 'टिप्पणियाँ (वैकल्पिक)';

  @override
  String get notesHint => 'कोई भी टिप्पणी जो आप जोड़ना चाहते हैं';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get userProfileNotFound => 'उपयोगकर्ता प्रोफ़ाइल नहीं मिली।';

  @override
  String get notAvailableAbbreviation => 'उपलब्ध नहीं';

  @override
  String get joinedAtLabel => 'इसमें शामिल हुए';

  @override
  String get userDataNotFound => 'उपयोगकर्ता डेटा नहीं मिला';

  @override
  String get sportLabel => 'खेल';

  @override
  String get dobLabel => 'जन्म तिथि';

  @override
  String get privacyTermsLink => 'गोपनीयता नीति और शर्तें';

  @override
  String get privacyTermsTitle => 'गोपनीयता और शर्तें';

  @override
  String get headerTagline =>
      'आपकी गोपनीयता और सुरक्षा हमारे लिए मायने रखती है';

  @override
  String get privacyPolicyTitle => 'गोपनीयता नीति';

  @override
  String get privacyPolicyIntro =>
      'एथलेटिक्स में, हम आपकी गोपनीयता का सम्मान करते हैं। यह नीति एथलीटों, प्रशिक्षकों, डॉक्टरों और संगठनों सहित सभी उपयोगकर्ताओं पर लागू होती है।';

  @override
  String get privacyBullet1 =>
      'हम आपके अनुभव को बेहतर बनाने के लिए व्यक्तिगत और व्यावसायिक जानकारी एकत्र करते हैं।';

  @override
  String get privacyBullet2 =>
      'आपका डेटा केवल आपकी भूमिका के पारिस्थितिकी तंत्र में अधिकृत व्यक्तियों के साथ साझा किया जाता है।';

  @override
  String get privacyBullet3 => 'हम आपका डेटा तीसरे पक्ष को नहीं बेचते हैं।';

  @override
  String get privacyBullet4 =>
      'आप किसी भी समय अपने डेटा को हटाने का अनुरोध कर सकते हैं।';

  @override
  String get termsConditionsTitle => 'नियम और शर्तें';

  @override
  String get termsIntro => 'एथलेटिक्स का उपयोग करके, आप सहमत हैं:';

  @override
  String get termsNumbered1 => 'सटीक पंजीकरण और प्रोफ़ाइल जानकारी प्रदान करें।';

  @override
  String get termsNumbered2 =>
      'मंच का सम्मानपूर्वक और जिम्मेदारी से उपयोग करें।';

  @override
  String get termsNumbered3 =>
      'अन्य उपयोगकर्ताओं के डेटा या संचार उपकरणों तक पहुंच का दुरुपयोग न करें।';

  @override
  String get termsNumbered4 =>
      'स्वीकार करें कि एथलेटिक्स स्वास्थ्य या प्रदर्शन डेटा के किसी भी दुरुपयोग के लिए उत्तरदायी नहीं है।';

  @override
  String get termsInfoBox =>
      'प्रत्येक भूमिका (एथलीट, कोच, डॉक्टर, संगठन) को उनकी पहुंच और जिम्मेदारियों के लिए विशिष्ट दिशानिर्देशों का पालन करना होगा।';

  @override
  String get lastUpdatedLabel => 'अंतिम अद्यतन';

  @override
  String get lastUpdatedDate => 'जनवरी 2025';

  @override
  String contactSupport(String email) {
    return 'प्रश्न? संपर्क करें: $email';
  }

  @override
  String get supportEmail => 'support@athletix.com';

  @override
  String get welcomeBackTitle => 'वापस स्वागत है';

  @override
  String get createAccountTitle => 'खाता बनाएँ';

  @override
  String get loginSubtitle => 'जारी रखने के लिए लॉग इन करें';

  @override
  String get signupSubtitle => 'शुरू करने के लिए साइन अप करें';

  @override
  String get loginButton => 'लॉग इन';

  @override
  String get signupButton => 'साइन अप करें';

  @override
  String get fullNameLabel => 'पूरा नाम';

  @override
  String get dateOfBirthLabel => 'जन्म तिथि';

  @override
  String get roleLabel => 'भूमिका';

  @override
  String get specializationLabel => 'विशेषज्ञता';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get roleAthlete => 'एथलीट';

  @override
  String get roleCoach => 'प्रशिक्षक';

  @override
  String get roleDoctor => 'डॉक्टर';

  @override
  String get userRoleNotFound => 'उपयोगकर्ता भूमिका नहीं मिली';

  @override
  String get notLoggedInMessage => 'लॉग इन नहीं है';

  @override
  String get signOutDialogTitle => 'साइन आउट करें';

  @override
  String get signOutConfirmationMessage =>
      'क्या आप वाकई साइन आउट करना चाहते हैं?';

  @override
  String get signOutButton => 'साइन आउट करें';

  @override
  String get signOutSuccessToast => 'सफलतापूर्वक साइन आउट किया गया';

  @override
  String signOutFailedToast(String error) {
    return 'साइन आउट करने में विफल: $error';
  }

  @override
  String get sportFootball => 'फ़ुटबॉल';

  @override
  String get sportBasketball => 'बास्केटबॉल';

  @override
  String get sportCricket => 'क्रिकेट';

  @override
  String get sportTennis => 'टेनिस';

  @override
  String get sportAthletics => 'एथलेटिक्स';

  @override
  String get sportSwimming => 'तैराकी';

  @override
  String get emailRequired => 'ईमेल आवश्यक है';

  @override
  String get emailInvalidFormat =>
      'एक वैध ईमेल का उपयोग करें (उदाहरण: @gmail.com, @yahoo.com, @outlook.com)';

  @override
  String get passwordRequired => 'पासवर्ड आवश्यक है';

  @override
  String passwordMinLength(int length) {
    return 'पासवर्ड कम से कम $length अक्षर लंबा होना चाहिए';
  }

  @override
  String get passwordUppercase =>
      'पासवर्ड में कम से कम एक बड़ा अक्षर होना चाहिए';

  @override
  String get passwordLowercase =>
      'पासवर्ड में कम से कम एक छोटा अक्षर होना चाहिए';

  @override
  String get passwordNumber => 'पासवर्ड में कम से कम एक संख्या होनी चाहिए';

  @override
  String get fullNameRequired => 'पूरा नाम आवश्यक है';

  @override
  String fullNameMinLength(int length) {
    return 'नाम कम से कम $length अक्षर लंबा होना चाहिए';
  }

  @override
  String get fullNameInvalidChars => 'नाम में केवल अक्षर और स्थान हो सकते हैं';

  @override
  String get dobRequired => 'जन्म तिथि आवश्यक है';

  @override
  String dobMinAge(int age) {
    return 'आपकी आयु कम से कम $age वर्ष होनी चाहिए';
  }

  @override
  String sportRequired(String field) {
    return '$field आवश्यक है';
  }

  @override
  String get fixErrorsMessage => 'कृपया त्रुटियों को ठीक करें';

  @override
  String checklistMinLength(int length) {
    return 'कम से कम $length अक्षर';
  }

  @override
  String get checklistUppercase => 'कम से कम एक बड़ा अक्षर';

  @override
  String get checklistLowercase => 'कम से कम एक छोटा अक्षर';

  @override
  String get checklistNumber => 'कम से कम एक संख्या';

  @override
  String get fieldRequired => 'आवश्यक';

  @override
  String get fillAllFieldsMessage => 'कृपया सभी फ़ील्ड भरें!';

  @override
  String get pleaseEnterActivityDate => 'कृपया गतिविधि और दिनांक दर्ज करें';

  @override
  String get pleaseEnterInjuryDate => 'कृपया चोट और दिनांक दर्ज करें';

  @override
  String get authErrorTitle => 'प्रमाणीकरण त्रुटि';

  @override
  String get authErrorEmailPassIncorrect =>
      'ईमेल या पासवर्ड गलत है। कृपया पुनः प्रयास करें।';

  @override
  String get authErrorInvalidEmail => 'ईमेल पता वैध नहीं है।';

  @override
  String get authErrorUserDisabled =>
      'यह उपयोगकर्ता खाता अक्षम कर दिया गया है।';

  @override
  String get authErrorEmailInUse =>
      'यह ईमेल पहले से पंजीकृत है। लॉग इन करने का प्रयास करें।';

  @override
  String get authErrorWeakPassword =>
      'आपका पासवर्ड कम से कम 8 अक्षर का होना चाहिए और उसमें एक संख्या होनी चाहिए।';

  @override
  String get authErrorOperationNotAllowed =>
      'यह ऑपरेशन अनुमत नहीं है। कृपया सहायता से संपर्क करें।';

  @override
  String get authErrorUnknown =>
      'एक अज्ञात त्रुटि हुई। कृपया पुनः प्रयास करें।';

  @override
  String get logoutTooltip => 'लॉग आउट करें';

  @override
  String get quickActionsTitle => 'त्वरित कार्य';

  @override
  String get navBarHome => 'होम';

  @override
  String get navBarPlayers => 'खिलाड़ी';

  @override
  String get navBarTournaments => 'टूर्नामेंट';

  @override
  String get navBarProfile => 'प्रोफ़ाइल';

  @override
  String get navBarCalendar => 'कैलेंडर';

  @override
  String get doctorDashboardTitle => 'डॉक्टर डैशबोर्ड';

  @override
  String get welcomeDoctorMessage => 'आपका स्वागत है, डॉक्टर!';

  @override
  String get coachDashboardTitle => 'कोच डैशबोर्ड';

  @override
  String get welcomeCoachMessage => 'आपका स्वागत है, कोच!';

  @override
  String get athleteDashboardTitle => 'डैशबोर्ड';

  @override
  String get injuryTrackerLabel => 'चोट ट्रैकर';

  @override
  String get performanceLogsLabel => 'प्रदर्शन लॉग';

  @override
  String get financialTrackerLabel => 'वित्तीय ट्रैकर';

  @override
  String get homeLabel => 'होम';

  @override
  String get playersLabel => 'खिलाड़ी';

  @override
  String get tournamentsLabel => 'टूर्नामेंट';

  @override
  String get profileLabel => 'प्रोफ़ाइल';

  @override
  String get timeTableLabel => 'समय सारणी';

  @override
  String get addTournamentTitle => 'टूर्नामेंट जोड़ें';

  @override
  String get tournamentNameLabel => 'टूर्नामेंट का नाम';

  @override
  String get levelLabel => 'स्तर';

  @override
  String get levelDistrict => 'जिला';

  @override
  String get levelState => 'राज्य';

  @override
  String get levelNational => 'राष्ट्रीय';

  @override
  String get levelInternational => 'अंतर्राष्ट्रीय';

  @override
  String get pickDateButton => 'दिनांक चुनें';

  @override
  String get pickTimeButton => 'समय चुनें';

  @override
  String get pickLocationButton => 'स्थान चुनें';

  @override
  String get locationPicked => 'स्थान चुना गया';

  @override
  String get saveTournamentButton => 'टूर्नामेंट सहेजें';

  @override
  String get locationPermissionDenied => 'स्थान की अनुमति अस्वीकृत।';

  @override
  String get locationPermissionDeniedForever =>
      'स्थान की अनुमतियाँ स्थायी रूप से अस्वीकृत हैं, कृपया उन्हें सेटिंग्स में सक्षम करें।';

  @override
  String get tournamentAddSuccessTitle => 'सफलता';

  @override
  String get tournamentAddSuccessContent => 'टूर्नामेंट सफलतापूर्वक जोड़ा गया!';

  @override
  String get pickLocationMapTitle => 'स्थान चुनें';

  @override
  String get managePlayersTitle => 'खिलाड़ियों को प्रबंधित करें';

  @override
  String get managePlayersScreenContent => 'खिलाड़ी प्रबंधन स्क्रीन';

  @override
  String get organizationDashboardTitle => 'संगठन डैशबोर्ड';

  @override
  String get tournamentsTitle => 'टूर्नामेंट';

  @override
  String get locationServicesDisabled => 'स्थान सेवाएँ अक्षम हैं।';

  @override
  String errorFetchingTournaments(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get noTournamentsFound => 'कोई टूर्नामेंट नहीं मिला।';

  @override
  String get dateLabel => 'दिनांक';

  @override
  String get timeLabel => 'समय';

  @override
  String get addressLabel => 'पता';

  @override
  String get calendarTitle => 'कैलेंडर';

  @override
  String get addActivityTitle => 'गतिविधि जोड़ें';

  @override
  String get workActivityLabel => 'कार्य/गतिविधि';

  @override
  String get selectStartTimeButton => 'प्रारंभ समय चुनें';

  @override
  String get startTimePrefix => 'प्रारंभ';

  @override
  String get selectEndTimeButton => 'समाप्ति समय चुनें';

  @override
  String get endTimePrefix => 'समाप्ति';

  @override
  String get noActivitiesToday => 'इस दिन के लिए कोई आगामी गतिविधि नहीं है।';

  @override
  String get addActivityFabTooltip => 'नई गतिविधि जोड़ें';

  @override
  String get performanceLogsTitle => 'प्रदर्शन लॉग';

  @override
  String get addLogFabLabel => 'लॉग जोड़ें';

  @override
  String get addLogFabTooltip => 'नया प्रदर्शन लॉग जोड़ें';

  @override
  String get addPerformanceLogTitle => 'प्रदर्शन लॉग जोड़ें';

  @override
  String get activityLabel => 'गतिविधि *';

  @override
  String get activityHint => 'आपने क्या किया?';

  @override
  String get deleteLogTitle => 'लॉग हटाएँ';

  @override
  String get deleteLogConfirmation =>
      'क्या आप वाकई इस प्रदर्शन लॉग प्रविष्टि को हटाना चाहते हैं?';

  @override
  String get noPerformanceLogsYet => 'अभी तक कोई प्रदर्शन लॉग नहीं।';

  @override
  String get logCardDatePrefix => 'दिनांक';

  @override
  String get logCardNotesPrefix => 'टिप्पणियाँ';

  @override
  String get deleteEntryTooltip => 'प्रविष्टि हटाएँ';

  @override
  String get injuryTrackerTitle => 'चोट ट्रैकर';

  @override
  String get addInjuryFabLabel => 'चोट जोड़ें';

  @override
  String get addInjurySheetTitle => 'चोट जोड़ें';

  @override
  String get injuryDescriptionLabel => 'चोट का विवरण *';

  @override
  String get injuryDescriptionHint => 'अपनी चोट का वर्णन करें';

  @override
  String get injuryDateLabel => 'चोट की तारीख *';

  @override
  String get deleteInjuryTitle => 'चोट हटाएँ';

  @override
  String get deleteInjuryConfirmation =>
      'क्या आप वाकई इस चोट प्रविष्टि को हटाना चाहते हैं?';

  @override
  String get noInjuriesLoggedYet => 'अभी तक कोई चोट दर्ज नहीं हुई है।';

  @override
  String get deleteInjuryTooltip => 'चोट हटाएँ';

  @override
  String get injuryCardDatePrefix => 'दिनांक';

  @override
  String get injuryCardNotesPrefix => 'टिप्पणियाँ';

  @override
  String get financialTrackerTitle => '💰 वित्तीय ट्रैकर';

  @override
  String get viewGraphTooltip => 'ग्राफ देखें';

  @override
  String get closeFormTooltip => 'फ़ॉर्म बंद करें';

  @override
  String get addEntryTooltip => 'प्रविष्टि जोड़ें';

  @override
  String get incomeType => 'आय';

  @override
  String get expenseType => 'खर्च';

  @override
  String get categoryLabel => 'श्रेणी';

  @override
  String get amountLabel => 'राशि';

  @override
  String get updateEntryButton => 'प्रविष्टि अपडेट करें';

  @override
  String get addEntryButton => 'प्रविष्टि जोड़ें';

  @override
  String get selectDateRangeTooltip => 'दिनांक सीमा चुनें';

  @override
  String get filterCategoryHint => 'श्रेणी फ़िल्टर करें';

  @override
  String get clearFiltersTooltip => 'फ़िल्टर साफ़ करें';

  @override
  String get viewTypeMonthly => 'मासिक';

  @override
  String get viewTypeWeekly => 'साप्ताहिक';

  @override
  String get viewTypeDaily => 'दैनिक';

  @override
  String get viewTypeYearly => 'वार्षिक';

  @override
  String get incomeSummary => 'आय';

  @override
  String get expenseSummary => 'खर्च';

  @override
  String get balanceSummary => 'शेष';

  @override
  String get transactionsHeading => 'लेन-देन';

  @override
  String get deleteTransactionDialogTitle => 'लेन-देन हटाएँ';

  @override
  String get deleteTransactionConfirmation =>
      'क्या आप वाकई इस लेन-देन को हटाना चाहते हैं?';

  @override
  String get loadingData => 'डेटा लोड हो रहा है...';

  @override
  String get noDataAvailable => 'कोई डेटा उपलब्ध नहीं है।';

  @override
  String get categorySalary => 'वेतन';

  @override
  String get categoryBonus => 'बोनस';

  @override
  String get categoryFreelance => 'फ्रीलांस';

  @override
  String get categoryInvestmentsIncome => 'निवेश';

  @override
  String get categoryGifts => 'उपहार';

  @override
  String get categoryRentIncome => 'किराया आय';

  @override
  String get categoryOtherIncome => 'अन्य आय';

  @override
  String get categoryFood => 'भोजन';

  @override
  String get categoryTransportation => 'परिवहन';

  @override
  String get categoryHousing => 'आवास';

  @override
  String get categoryUtilities => 'उपयोगिताएँ';

  @override
  String get categoryEntertainment => 'मनोरंजन';

  @override
  String get categoryShopping => 'खरीदारी';

  @override
  String get categoryHealth => 'स्वास्थ्य';

  @override
  String get categoryEducation => 'शिक्षा';

  @override
  String get categoryTravel => 'यात्रा';

  @override
  String get categoryGroceries => 'किराना';

  @override
  String get categoryDiningOut => 'बाहर खाना';

  @override
  String get categoryLoans => 'ऋण';

  @override
  String get categoryInsurance => 'बीमा';

  @override
  String get categorySavings => 'बचत';

  @override
  String get categoryInvestmentsExpense => 'निवेश (खर्च)';

  @override
  String get categoryOtherExpenses => 'अन्य खर्च';

  @override
  String get incomeExpensesChartTitle => 'आय और व्यय';

  @override
  String get currencySymbol => '₹';

  @override
  String get dayMon => 'सोम';

  @override
  String get dayTue => 'मंगल';

  @override
  String get dayWed => 'बुध';

  @override
  String get dayThu => 'गुरु';

  @override
  String get dayFri => 'शुक्र';

  @override
  String get daySat => 'शनि';

  @override
  String get daySun => 'रवि';

  @override
  String get monthJan => 'जनवरी';

  @override
  String get monthFeb => 'फरवरी';

  @override
  String get monthMar => 'मार्च';

  @override
  String get monthApr => 'अप्रैल';

  @override
  String get monthMay => 'मई';

  @override
  String get monthJun => 'जून';

  @override
  String get monthJul => 'जुलाई';

  @override
  String get monthAug => 'अगस्त';

  @override
  String get monthSep => 'सितंबर';

  @override
  String get monthOct => 'अक्टूबर';

  @override
  String get monthNov => 'नवंबर';

  @override
  String get monthDec => 'दिसंबर';

  @override
  String get weekPrefix => 'सप्ताह';

  @override
  String get loadingDashboard => 'आपका डैशबोर्ड लोड हो रहा है...';

  @override
  String get refreshPrompt => 'कृपया पृष्ठ को रीफ्रेश करने का प्रयास करें';

  @override
  String get refreshButton => 'रीफ्रेश करें';

  @override
  String get greetingMorning => 'सुप्रभात';

  @override
  String get greetingAfternoon => 'शुभ दोपहर';

  @override
  String get greetingEvening => 'शुभ संध्या';

  @override
  String get notSetLabel => 'सेट नहीं है';

  @override
  String get monitorHealthSubtitle => 'अपने स्वास्थ्य की निगरानी करें';

  @override
  String get performanceLabel => 'प्रदर्शन';

  @override
  String get trackProgressSubtitle => 'अपनी प्रगति को ट्रैक करें';

  @override
  String get financesLabel => 'वित्त';

  @override
  String get manageExpensesSubtitle => 'खर्चों का प्रबंधन करें';

  @override
  String get thisWeekTitle => 'इस सप्ताह';

  @override
  String get trainingSessionsTitle => 'प्रशिक्षण सत्र';

  @override
  String get hoursTrainedTitle => 'प्रशिक्षित घंटे';

  @override
  String get errorPrefix => 'त्रुटि';

  @override
  String get tournamentLevelLabel => 'स्तर';

  @override
  String get newUserPrompt => 'नए उपयोगकर्ता?';

  @override
  String get alreadyHaveAccountPrompt => 'पहले से ही खाता है?';

  @override
  String get viewTournamentsLabel => 'टूर्नामेंट देखें';

  @override
  String get dismissButton => 'खारिज करें';

  @override
  String get emailVerificationRequiredTitle => 'ईमेल सत्यापन आवश्यक है';

  @override
  String emailVerificationInstructionMessage(Object email) {
    return 'हमने $email पर एक सत्यापन ईमेल भेजा है';
  }

  @override
  String get checkInboxSpamMessage =>
      'कृपया अपना इनबॉक्स और स्पैम फ़ोल्डर जांचें, फिर सत्यापन लिंक पर क्लिक करें। सत्यापित होने के बाद, जारी रखने के लिए \"मैंने सत्यापित कर लिया है\" पर क्लिक करें।';

  @override
  String get sendingButton => 'भेजा जा रहा है...';

  @override
  String get resendEmailButton => 'ईमेल पुनः भेजें';

  @override
  String get checkingButton => 'जांच रहा है...';

  @override
  String get iveVerifiedButton => 'मैंने सत्यापित कर लिया है';

  @override
  String get goBackButton => 'वापस जाएं';

  @override
  String get welcomeGreeting => 'वापस स्वागत है,';

  @override
  String doctorName(Object name) {
    return 'डॉ. $name';
  }

  @override
  String get profileInfoTitle => 'प्रोफ़ाइल जानकारी';

  @override
  String get yourProfessionalDetails => 'आपके पेशेवर विवरण';

  @override
  String get notSpecified => 'निर्दिष्ट नहीं';

  @override
  String get accessToolsSubtitle =>
      'अपने उपकरणों तक पहुंचें और अपनी प्रैक्टिस का प्रबंधन करें';

  @override
  String get qualificationsAndLicense => 'योग्यता और लाइसेंस';

  @override
  String get announcements => 'घोषणाएँ';

  @override
  String get informationCenter => 'सूचना केंद्र';

  @override
  String get filterActivityHint => 'गतिविधि फ़िल्टर करें';

  @override
  String logsFilteredBy(Object dateFilter, Object activityFilter) {
    return '$dateFilter के लिए लॉग दिखा रहा है | $activityFilter द्वारा फ़िल्टर किया गया';
  }

  @override
  String get allDatesLabel => 'सभी तारीखें';

  @override
  String get allActivitiesLabel => 'सभी गतिविधियां';
}
