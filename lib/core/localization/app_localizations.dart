import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App General
      'app_name': 'Task Tracker',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'submit': 'Submit',
      'skip': 'Skip',
      'continue': 'Continue',
      'yes': 'Yes',
      'no': 'No',
      'error': 'Error',
      'route_not_found': 'Route not found!',
      'goto_login': 'Go to Login',
      'path': 'Path',
      'unknown_path': 'Unknown Path',
      "priority": "Priority",
      "priorityHigh": "High",
      "priorityMedium": "Medium",
      "priorityLow": "Low",
      'category': 'Category',
      'other': 'Other',
      'personal': 'Personal',
      'work': 'Work',
      'update': 'Update',
      'create': 'Create',

      // Authentication
      'login': 'Login',
      'signup': 'Sign Up',
      'register': 'Register',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'email_address': 'Email Address',
      'forgot_password': 'Forgot Password?',
      'remember_me': 'Remember me',
      'dont_have_account': "Don't have an account?",
      'already_have_account': 'Already have an account?',

      // Validation
      'email_required': 'Email is required',
      'invalid_email': 'Please enter a valid email',
      'password_required': 'Password is required',
      'password_min_length':
          'Password must be at least ${AppConstants.minPasswordLength} characters',
      'password_max_length':
          'Password must not exceed ${AppConstants.maxPasswordLength} characters',
      'password_one_number': 'Add at least one number or special character',
      'password_one_uppercase': 'Add at least one uppercase letter',
      'title_is_required': 'Title is required',
      'description_is_required': 'Description is required',

      // Login Screen
      'login_title': 'Login',
      'login_subtitle': 'By signing in, you agree to our',
      'terms_privacy': 'Terms & Privacy Policy.',

      // Signup Screen
      'signup_title': 'Welcome',
      'signup_subtitle': 'By signing up, you agree to our',
      'create_account': 'Create Account',

      // Forgot Password
      'forgot_password_title': 'Forget Password',
      'forgot_password_subtitle':
          'Enter your email and we will send you a password reset link',
      'reset_email_sent':
          'If an account exists for this email, you will receive a reset link shortly.',
      'reset_email_failed': 'Failed to send reset email',

      // Onboarding
      'onboarding_title': 'Task Management & To-Do List',
      'onboarding_description':
          'This productive tool is designed to help you better manage your task project-wise conveniently!',
      'lets_start': "Let's Start",

      // Email Verification
      'verify_email': 'Verify your email',
      'verify_email_msg':
          'We have sent a verification link to your register email. Please verify your account to continue',
      'resend_email': "Resend Email",
      'resend_in': "Resend in",
      'another_account': 'Use another account',

      // Auth Messages
      'login_success': 'Login successful',
      'login_failed': 'Login failed',
      'signup_success': 'Account created successfully',
      'signup_failed': 'Failed to create account',
      'logout_success': 'Logged out successfully',
      'logout_failed': 'Logout failed',

      // Errors
      'error_occurred': 'An error occurred',
      'network_error': 'Network error. Please check your connection',
      'server_error': 'Server error. Please try again later',
      'invalid_credentials': 'Invalid email or password',
      'user_not_found': 'User not found',
      'email_already_exists': 'Email already in use',
      'weak_password': 'Password is too weak',
      'user_profile_error': 'User Profile could not save. Please login again!',

      // Home & Tasks
      'add_task': 'Add Task',
      'edit_task': 'Edit Task',
      'task_title': 'Task Title',
      'task_description': 'Task Description',
      'start_date': 'Start Date',
      'end_date': 'End Date',
      'pending': 'Pending',
      'completed': 'Completed',
      'pending_tasks': 'Pending Tasks',
      'completed_tasks': 'Completed Tasks',
      'task_title_label': 'What are you planning? 😇',
      'task_description_label': 'Write a task description 📝',
      'due_date': 'Due Date',
      'task': 'Task',
      'task_create': 'Task Created Successfully',
      'task_update': 'Task Updated Successfully',
      'task_delete': 'Task Deleted Successfully',
      'task_complete': 'Task Completed Successfully',
      'task_incomplete': 'Task was Incomplete',
      'task_delete_confirm': 'Are you sure you want to delete this task?',
      'task_complete_confirm': 'Have you completed this task?',
      'task_incomplete_confirm': 'Are you sure you want to mark this task as incomplete?',
      'today': 'Today',
      'overdue': 'Overdue',
      'finish': 'Finish',
      'on_time': 'On Time',
      'delete_task': 'Delete Task',
      'complete_task': 'Complete Task',
      'incomplete_task': 'InComplete Task',
      'completing_task': 'Completing Task...',
      'in_completing_task': 'InCompleting Task...',
      'deleting_task': 'Deleting Task...',
      'updating_task': 'Updating Task...',
      'creating_task': 'Creating Task...',

      // Settings
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'notifications': 'Notifications',
      'profile': 'Profile',

      // Theme Options
      'light_theme': 'Light',
      'dark_theme': 'Dark',
      'system_theme': 'System',

      // Fields
      'field_required': 'This field is required',
      'name_required': 'Name is required',
      'name_short': 'Name must be at least 3 characters',
      'name_long': 'Name must not exceed 30 characters',
      'name_invalid': 'Name contains invalid characters',
      'phone_required': 'Phone number is required',
      'valid_number': 'Please enter a valid 10-digit phone number',
      'date_required': 'Date is required',

      // Firebase Exceptions
      'user-not-found': 'No user found with this email',
      'wrong-password': 'Incorrect password',
      'email-already-in-use': 'An account already exists with this email',
      'invalid-email': 'Invalid email address',
      'weak-password': 'Password is too weak',
      'user-disabled': 'This account has been disabled',
      'too-many-requests': 'Too many attempts. Please try again later',
      'operation-not-allowed': 'Operation not allowed',
      'invalid-credential': 'Invalid credentials provided',
      'network-request-failed': 'Network error. Please check your connection',
      'authentication-error': 'Authentication error occurred',

      // Throws Exceptions
      'login_failed_no_user': 'Login failed: No user returned',
      'registration_failed_no_user': 'Registration failed: No user returned',
      'unexpected_error': 'Unexpected error occur',
      'not-found': 'Some requested document was not found',
      'user-profile-error':
          "User profile not exist, Let's set up your profile!",

      //Loading Message
      'logging_in': 'Logging in...',
      'reset_link': 'Reset link...',
      'signing_up': 'Signing up...',
      'email_verifying': 'Email verifying...',

      // Local Storage Message
      'remember_me_failed': "Couldn't load saved login. Sign in manually",

      // Drawer / Navigation
      'home': 'Home',
      'profile_label': 'Profile',
      'name_label': 'Name',
      'email_label': 'Email',
      'na': 'NA',
      'back_to_home': 'Back To Home',

      // Profile Setup & Display
      'profile_setup_title': 'Set Up Your Profile',
      'first_name': 'First Name',
      'last_name': 'Last Name',
      'gender': 'Gender',
      'age': 'Age',
      'location': 'Location',
      'save_profile': 'Save Profile',
      'first_name_required': 'First name is required',
      'email_required_profile': 'Email is required',
      'tap_to_add_photo': 'Tap to add photo',
      'choose_photo_source': 'Choose Photo Source',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'member_since': 'Member since',
      'statistics': 'Statistics',
      'total_tasks': 'Total',
      'pending_label': 'Pending',
      'completed_label': 'Completed',
      'edit_profile': 'Edit Profile',
      'sign_out': 'Sign Out',
      'profile_updated': 'Profile updated successfully',
      'profile_updating': 'Profile updating...',
      'male': 'Male',
      'female': 'Female',
      'other_gender': 'Other',
      'prefer_not_to_say': 'Prefer not to say',
      'profile_saving': 'Saving profile...',
      'enter_age': 'Enter your age',
      'enter_location': 'Enter your location',
      'current_streak': 'Current Streak',
      'longest_streak': 'Longest Streak',
      'day_streak': 'day',
      'days_streak': 'days',

      // Screens Name
      'task_screen': "Task Tracker",
      'setting_screen': "App Settings",
      'profile_screen': "User Profile",
      'default_screen': "Invalid Screen",
    },

    'hi': {
      // App General
      'app_name': 'टास्क ट्रैकर',
      'ok': 'ठीक है',
      'cancel': 'रद्द करें',
      'save': 'सहेजें',
      'delete': 'मिटाएं',
      'edit': 'संपादित करें',
      'submit': 'जमा करें',
      'skip': 'छोड़ें',
      'continue': 'जारी रखें',
      'yes': 'हाँ',
      'no': 'नहीं',
      'error': 'गलती',
      'route_not_found': 'मार्ग नहीं मिला!',
      'goto_login': 'लॉगइन पर जाएं',
      'path': 'पथ',
      'unknown_path': 'अज्ञात पथ',
      "priority": "प्राथमिकता",
      "priorityHigh": "उच्च",
      "priorityMedium": "मध्यम",
      "priorityLow": "कम",
      'category': 'वर्ग',
      'other': 'अन्य',
      'personal': 'निजी',
      'work': 'काम',
      'update': 'अद्यतन',
      'create': 'निर्माण',

      // Authentication
      'login': 'लॉगिन',
      'signup': 'साइन अप',
      'register': 'पंजीकरण करें',
      'logout': 'लॉगआउट',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'email_address': 'ईमेल पता',
      'forgot_password': 'पासवर्ड भूल गए?',
      'remember_me': 'मुझे याद रखें',
      'dont_have_account': 'खाता नहीं है?',
      'already_have_account': 'पहले से खाता है?',

      // Validation
      'email_required': 'ईमेल आवश्यक है',
      'invalid_email': 'कृपया एक वैध ईमेल दर्ज करें',
      'password_required': 'पासवर्ड आवश्यक है',
      'password_min_length':
          'पासवर्ड कम से कम ${AppConstants.minPasswordLength} अक्षरों का होना चाहिए',
      'password_max_length':
          'पासवर्ड ${AppConstants.maxPasswordLength} अक्षरों से अधिक नहीं होना चाहिए',
      'password_one_number': 'कम से कम एक संख्या या विशेष वर्ण जोड़ें',
      'password_one_uppercase': 'कम से कम एक बड़ा अक्षर जोड़ें',
      'title_is_required': 'शीर्षक आवश्यक है',
      'description_is_required': 'विवरण आवश्यक है',

      // Login Screen
      'login_title': 'लॉगिन',
      'login_subtitle': 'साइन इन करके, आप हमारी शर्तों से सहमत हैं',
      'terms_privacy': 'नियम और गोपनीयता नीति।',

      // Signup Screen
      'signup_title': 'स्वागत है',
      'signup_subtitle': 'साइन अप करके, आप हमारी शर्तों से सहमत हैं',
      'create_account': 'खाता बनाएं',

      // Forgot Password
      'forgot_password_title': 'पासवर्ड भूल गए',
      'forgot_password_subtitle':
          'अपना ईमेल दर्ज करें और हम आपको पासवर्ड रीसेट लिंक भेजेंगे',
      'reset_email_sent':
          'यदि इस ईमेल पते से कोई खाता मौजूद है, तो आपको शीघ्र ही एक रीसेट लिंक प्राप्त होगा।',
      'reset_email_failed': 'रीसेट ईमेल भेजने में विफल',

      // Onboarding
      'onboarding_title': 'कार्य प्रबंधन और करने के लिए सूची',
      'onboarding_description':
          'यह उत्पादक उपकरण आपको अपने कार्यों को बेहतर तरीके से प्रबंधित करने में मदद करने के लिए डिज़ाइन किया गया है!',
      'lets_start': 'शुरू करें',

      // Email Verification
      'verify_email': 'अपना ईमेल सत्यापित करें',
      'verify_email_msg':
          'हमने आपके पंजीकृत ईमेल पर एक सत्यापन लिंक भेजा है। कृपया जारी रखने के लिए अपना खाता सत्यापित करें।',
      'resend_email': "ईमेल दुबारा भेजें",
      'resend_in': "पुनः भेजें",
      'another_account': 'दूसरे खाते का उपयोग करें',

      // Auth Messages
      'login_success': 'लॉगिन सफल',
      'login_failed': 'लॉगिन विफल',
      'signup_success': 'खाता सफलतापूर्वक बनाया गया',
      'signup_failed': 'खाता बनाने में विफल',
      'logout_success': 'सफलतापूर्वक लॉगआउट',
      'logout_failed': 'लॉगआउट विफल',

      // Errors
      'error_occurred': 'एक त्रुटि हुई',
      'network_error': 'नेटवर्क त्रुटि। कृपया अपना कनेक्शन जांचें',
      'server_error': 'सर्वर त्रुटि। कृपया बाद में पुनः प्रयास करें',
      'invalid_credentials': 'अमान्य ईमेल या पासवर्ड',
      'user_not_found': 'उपयोगकर्ता नहीं मिला',
      'email_already_exists': 'ईमेल पहले से उपयोग में है',
      'weak_password': 'पासवर्ड बहुत कमजोर है',
      'user_profile_error': 'उपयोगकर्ता प्रोफ़ाइल सहेजी नहीं जा सकी। कृपया पुनः लॉगिन करें!',

      // Home & Tasks
      'add_task': 'कार्य जोड़ें',
      'edit_task': 'कार्य संपादित करें',
      'task_title': 'कार्य शीर्षक',
      'task_description': 'कार्य विवरण',
      'start_date': 'प्रारंभ तिथि',
      'end_date': 'समाप्ति तिथि',
      'pending': 'अपूर्ण',
      'completed': 'समाप्त',
      'pending_tasks': 'अपूर्ण कार्य',
      'completed_tasks': 'पूर्ण कार्य',
      'task_title_label': 'आप क्या योजना बना रहे हैं? 😇',
      'task_description_label': 'कार्य का विवरण लिखें 📝',
      'due_date': 'देय तिथि',
      'task': 'कार्य',
      'task_create': 'कार्य सफलतापूर्वक निर्मित हो गया',
      'task_update': 'कार्य सफलतापूर्वक अद्यतन किया गया',
      'task_delete': 'कार्य सफलतापूर्वक हटा दिया गया',
      'task_complete': 'कार्य सफलतापूर्वक पूरा हुआ',
      'task_incomplete': 'कार्य अधूरा था',
      'task_delete_confirm': 'क्या आप वाकई इस कार्य को हटाना चाहते हैं?',
      'task_complete_confirm': 'क्या आपने यह कार्य पूरा कर लिया है?',
      'task_incomplete_confirm': 'क्या आप वाकई इस कार्य को अपूर्ण के रूप में चिह्नित करना चाहते हैं?',
      'today': 'आज',
      'overdue': 'बाकी',
      'finish': 'समाप्त',
      'on_time': 'समय पर',
      'delete_task': 'कार्य हटाएँ',
      'complete_task': 'पूरा कार्य',
      'incomplete_task': 'अधूरा कार्य',
      'completing_task': 'कार्य पूरा हो रहा है...',
      'deleting_task': 'कार्य हटाया जा रहा है...',
      'updating_task': 'कार्य अद्यतन हो रहा है...',
      'creating_task': 'कार्य बनाया जा रहा है...',
      'in_completing_task': 'कार्य पूरा नहीं हुआ...',

      // Settings
      'settings': 'सेटिंग्स',
      'theme': 'थीम',
      'language': 'भाषा',
      'notifications': 'सूचनाएं',
      'profile': 'प्रोफ़ाइल',

      // Theme Options
      'light_theme': 'लाइट',
      'dark_theme': 'डार्क',
      'system_theme': 'सिस्टम',

      // Fields
      'field_required': 'यह फ़ील्ड आवश्यक है',
      'name_required': 'नाम आवश्यक है',
      'name_short': 'नाम कम से कम 3 अक्षरों का होना चाहिए',
      'name_long': 'नाम 30 अक्षरों से अधिक नहीं होना चाहिए',
      'name_invalid': 'नाम में अमान्य अक्षर हैं',
      'phone_required': 'फ़ोन नंबर आवश्यक है',
      'valid_number': 'कृपया एक वैध 10 अंकों का फ़ोन नंबर दर्ज करें',
      'date_required': 'दिनांक आवश्यक है',

      // Firebase Exceptions
      'user-not-found': 'इस ईमेल पते से कोई उपयोगकर्ता नहीं मिला।',
      'wrong-password': 'गलत पासवर्ड',
      'email-already-in-use': 'इस ईमेल पते से पहले से ही एक खाता मौजूद है।',
      'invalid-email': 'अमान्य ईमेल पता',
      'weak-password': 'पासवर्ड बहुत कमजोर है',
      'user-disabled': 'यह खाता बंद कर दिया गया है',
      'too-many-requests': 'कई सारे प्रयास। कृपया बाद में दोबारा प्रयास करें',
      'operation-not-allowed': 'संचालन की अनुमति नहीं है',
      'invalid-credential': 'अमान्य क्रेडेंशियल प्रदान किए गए',
      'network-request-failed':
          'नेटवर्क में गड़बड़ी। कृपया अपना कनेक्शन जांचें।',
      'authentication-error': 'प्रमाणीकरण त्रुटि हुई',

      // Throws Exceptions
      'login_failed_no_user': 'लॉगिन विफल: कोई उपयोगकर्ता नहीं मिला',
      'registration_failed_no_user': 'पंजीकरण विफल: कोई उपयोगकर्ता नहीं मिला',
      'unexpected_error': 'अप्रत्याशित त्रुटि उत्पन्न हुई',
      'not-found': 'अनुरोधित दस्तावेज़ नहीं मिला',
      'user-profile-error':
          'उपयोगकर्ता प्रोफ़ाइल मौजूद नहीं है, आइए आपकी प्रोफ़ाइल बनाते हैं!',

      // Loading Message
      'logging_in': 'लॉगिन हो रहा है...',
      'reset_link': 'रीसेट लिंक...',
      'signing_up': 'साइन अप हो रहा है...',
      'email_verifying': 'ईमेल सत्यापित हो रहा है...',

      // Local Storage Message
      'remember_me_failed':
          "सहेजा गया लॉगिन लोड नहीं हो सका। कृपया मैन्युअल रूप से साइन इन करें।",

      // Drawer / Navigation
      'home': 'होम',
      'profile_label': 'प्रोफ़ाइल',
      'name_label': 'नाम',
      'email_label': 'ईमेल',
      'na': 'उपलब्ध नहीं',
      'back_to_home': 'होम पर वापस जाएं',

      // Profile Setup & Display
      'profile_setup_title': 'अपनी प्रोफ़ाइल सेट करें',
      'first_name': 'पहला नाम',
      'last_name': 'अंतिम नाम',
      'gender': 'लिंग',
      'age': 'आयु',
      'location': 'स्थान',
      'save_profile': 'प्रोफ़ाइल सहेजें',
      'first_name_required': 'पहला नाम आवश्यक है',
      'email_required_profile': 'ईमेल आवश्यक है',
      'tap_to_add_photo': 'फ़ोटो जोड़ने के लिए टैप करें',
      'choose_photo_source': 'फ़ोटो स्रोत चुनें',
      'camera': 'कैमरा',
      'gallery': 'गैलरी',
      'member_since': 'सदस्य',
      'statistics': 'आंकड़े',
      'total_tasks': 'कुल',
      'pending_label': 'लंबित',
      'completed_label': 'पूर्ण',
      'edit_profile': 'प्रोफ़ाइल संपादित करें',
      'sign_out': 'साइन आउट',
      'profile_updated': 'प्रोफ़ाइल सफलतापूर्वक अपडेट हुई',
      'profile_updating': 'प्रोफ़ाइल अपडेट हो रही है...',
      'male': 'पुरुष',
      'female': 'महिला',
      'other_gender': 'अन्य',
      'prefer_not_to_say': 'बताना नहीं चाहते',
      'profile_saving': 'प्रोफ़ाइल सहेजी जा रही है...',
      'enter_age': 'अपनी आयु दर्ज करें',
      'enter_location': 'अपना स्थान दर्ज करें',
      'current_streak': 'वर्तमान स्ट्रीक',
      'longest_streak': 'सबसे लंबी स्ट्रीक',
      'day_streak': 'दिन',
      'days_streak': 'दिन',

      // Screens Name
      'task_screen': "कार्य ट्रैकर",
      'setting_screen': "ऐप सेटिंग्स",
      'profile_screen': "उपयोगकर्ता प्रोफ़ाइल",
      'default_screen': "अमान्य स्क्रीन",
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Helper getter methods
  String get appName => translate('app_name');
  String get login => translate('login');
  String get signup => translate('signup');
  String get email => translate('email');
  String get password => translate('password');
  String get emailAddress => translate('email_address');
  String get forgotPassword => translate('forgot_password');
  String get rememberMe => translate('remember_me');
  String get dontHaveAccount => translate('dont_have_account');
  String get alreadyHaveAccount => translate('already_have_account');
  String get register => translate('register');
  String get emailRequired => translate('email_required');
  String get invalidEmail => translate('invalid_email');
  String get passwordRequired => translate('password_required');
  String get passwordMinLength => translate('password_min_length');
  String get passwordMaxLength => translate('password_max_length');
  String get passwordOneNumber => translate('password_one_number');
  String get passwordOneUppercase => translate('password_one_uppercase');
  String get loginTitle => translate('login_title');
  String get loginSubtitle => translate('login_subtitle');
  String get termsPrivacy => translate('terms_privacy');
  String get signupTitle => translate('signup_title');
  String get signupSubtitle => translate('signup_subtitle');
  String get forgotPasswordTitle => translate('forgot_password_title');
  String get forgotPasswordSubtitle => translate('forgot_password_subtitle');
  String get submit => translate('submit');
  String get onboardingTitle => translate('onboarding_title');
  String get onboardingDescription => translate('onboarding_description');
  String get letsStart => translate('lets_start');
  String get fieldRequired => translate('field_required');
  String get phoneRequired => translate('phone_required');
  String get validNumber => translate('valid_number');
  String get loginFailedNoUser => translate('login_failed_no_user');
  String get registrationFailedNoUser =>
      translate('registration_failed_no_user');
  String get verifyEmail => translate('verify_email');
  String get verifyEmailMsg => translate('verify_email_msg');
  String get resendEmail => translate('resend_email');
  String get resendIn => translate('resend_in');
  String get anotherAccount => translate('another_account');
  String get taskScreen => translate('task_screen');
  String get profileScreen => translate('profile_screen');
  String get settingScreen => translate('setting_screen');
  String get defaultScreen => translate('default_screen');

  String get priority => translate('priority');
  String get priorityHigh => translate('priorityHigh');
  String get priorityMedium => translate('priorityMedium');
  String get priorityLow => translate('priorityLow');
  String get category => translate('category');
  String get personal => translate('personal');
  String get other => translate('other');
  String get work => translate('work');
  String get addTask => translate('add_task');
  String get taskTitleLabel => translate('task_title_label');
  String get taskDescriptionLabel => translate('task_description_label');
  String get dueDate => translate('due_date');
  String get cancel => translate('cancel');
  String get titleIsRequired => translate('title_is_required');
  String get descriptionIsRequired => translate('description_is_required');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
