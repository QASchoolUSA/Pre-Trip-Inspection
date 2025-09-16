/// Generated file. Do not edit.
///
/// This file contains the localization strings for the PTI Mobile App.
/// To add new strings, edit the ARB files in lib/l10n/ and run:
/// flutter gen-l10n

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('es'),
    Locale('ru'),
    Locale('uk')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'PTI Mobile App'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Inspections page title
  ///
  /// In en, this message translates to:
  /// **'Inspections'**
  String get inspections;

  /// New inspection button text
  ///
  /// In en, this message translates to:
  /// **'New Inspection'**
  String get newInspection;

  /// Pre-trip inspection type
  ///
  /// In en, this message translates to:
  /// **'Pre-Trip'**
  String get preTrip;

  /// Post-trip inspection type
  ///
  /// In en, this message translates to:
  /// **'Post-Trip'**
  String get postTrip;

  /// Annual inspection type
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annual;

  /// Vehicle selection page title
  ///
  /// In en, this message translates to:
  /// **'Vehicle Selection'**
  String get vehicleSelection;

  /// Select vehicle instruction
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get selectVehicle;

  /// Scan QR code button text
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// Manual entry button text
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntry;

  /// Vehicle number field label
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number'**
  String get vehicleNumber;

  /// License plate field label
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get licensePlate;

  /// Vehicle identification number
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get vin;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Pass status for inspection items
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get pass;

  /// Fail status for inspection items
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get fail;

  /// Not applicable status for inspection items
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notApplicable;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Completed status label
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// In progress status
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// Category name for cab and safety equipment
  ///
  /// In en, this message translates to:
  /// **'Cab and Safety Equipment'**
  String get cabAndSafetyEquipment;

  /// Category name for exterior and coupling system
  ///
  /// In en, this message translates to:
  /// **'Exterior and Coupling System'**
  String get exteriorAndCouplingSystem;

  /// Category name for engine compartment
  ///
  /// In en, this message translates to:
  /// **'Engine Compartment'**
  String get engineCompartment;

  /// Inspection category
  ///
  /// In en, this message translates to:
  /// **'Under Vehicle'**
  String get underVehicle;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Button text to save and exit
  ///
  /// In en, this message translates to:
  /// **'Save & Exit'**
  String get saveAndExit;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Previous button text
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Complete button text
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Label for notes indicator
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Button text to add notes to inspection item
  ///
  /// In en, this message translates to:
  /// **'Add Notes'**
  String get addNotes;

  /// Notes added status
  ///
  /// In en, this message translates to:
  /// **'Notes Added'**
  String get notesAdded;

  /// Photos label
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// Button text to add photos to inspection item
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// Button text to take a photo
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Select from gallery button text
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// Signature label
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signature;

  /// Add signature button text
  ///
  /// In en, this message translates to:
  /// **'Add Signature'**
  String get addSignature;

  /// Clear button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Defect severity label
  ///
  /// In en, this message translates to:
  /// **'Defect Severity'**
  String get defectSeverity;

  /// Minor defect severity
  ///
  /// In en, this message translates to:
  /// **'Minor'**
  String get minor;

  /// Major defect severity
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get major;

  /// Critical defect severity
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// Label for required inspection items
  ///
  /// In en, this message translates to:
  /// **'REQUIRED'**
  String get required;

  /// Optional field indicator
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// Language selection label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Russian language option
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// Ukrainian language option
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get ukrainian;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// App preferences subtitle text
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get appPreferences;

  /// Profile page title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Warning message
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Info message
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No data message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Refresh button text
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Filter button text
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Sort button text
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Time label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Location label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Driver label
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// Vehicle label
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// Report label
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// Generate report button text
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// Download report button text
  ///
  /// In en, this message translates to:
  /// **'Download Report'**
  String get downloadReport;

  /// Share report button text
  ///
  /// In en, this message translates to:
  /// **'Share Report'**
  String get shareReport;

  /// PIN entry instruction
  ///
  /// In en, this message translates to:
  /// **'Enter Your PIN'**
  String get enterYourPin;

  /// PIN input field hint
  ///
  /// In en, this message translates to:
  /// **'••••'**
  String get pinHint;

  /// Vehicle search field hint
  ///
  /// In en, this message translates to:
  /// **'Search by unit number, make, model...'**
  String get searchVehicleHint;

  /// Defect severity label with colon
  ///
  /// In en, this message translates to:
  /// **'Defect Severity:'**
  String get defectSeverityLabel;

  /// Number of photos attached to inspection item
  ///
  /// In en, this message translates to:
  /// **'{count} photo{count, plural, =1{} other{s}} attached to this item'**
  String photosAttachedToItem(int count);

  /// Critical defects warning title
  ///
  /// In en, this message translates to:
  /// **'Critical Defects Found'**
  String get criticalDefectsFound;

  /// Critical defects warning message
  ///
  /// In en, this message translates to:
  /// **'This vehicle has critical defects that may require immediate attention.'**
  String get criticalDefectsWarning;

  /// Out of service defect severity
  ///
  /// In en, this message translates to:
  /// **'Out of Service'**
  String get outOfService;

  /// Inspection completion message
  ///
  /// In en, this message translates to:
  /// **'Inspection completed! All {count} items finished ✓'**
  String inspectionCompleted(int count);

  /// Items completion progress
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} items completed'**
  String itemsCompleted(int completed, int total);

  /// No description provided for @photosAttached.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No photos} =1{1 photo attached} other{{count} photos attached}}'**
  String photosAttached(num count);

  /// Title for inspection page
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get inspection;

  /// Failed status label
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// OK status
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Overall notes section title
  ///
  /// In en, this message translates to:
  /// **'Overall Notes (Optional)'**
  String get overallNotes;

  /// Hint text for overall notes field
  ///
  /// In en, this message translates to:
  /// **'Add any overall notes about this inspection...'**
  String get overallNotesHint;

  /// Driver signature section title
  ///
  /// In en, this message translates to:
  /// **'Driver Signature'**
  String get driverSignature;

  /// Instruction text for signature
  ///
  /// In en, this message translates to:
  /// **'Please sign below to certify that you have completed this inspection.'**
  String get signatureInstruction;

  /// Certification section title
  ///
  /// In en, this message translates to:
  /// **'Certification'**
  String get certification;

  /// Certification disclaimer text
  ///
  /// In en, this message translates to:
  /// **'By signing below, I certify that I have completed this pre-trip inspection in accordance with DOT regulations and that all defects have been properly documented.'**
  String get certificationText;

  /// Back to inspection button text
  ///
  /// In en, this message translates to:
  /// **'Back to Inspection'**
  String get backToInspection;

  /// Button text to complete inspection
  ///
  /// In en, this message translates to:
  /// **'Complete Inspection'**
  String get completeInspection;

  /// Help page title
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Content text displayed on the help page
  ///
  /// In en, this message translates to:
  /// **'Help Page'**
  String get helpPageContent;

  /// Offline sync page content placeholder
  ///
  /// In en, this message translates to:
  /// **'Offline Sync Page'**
  String get offlineSyncPageContent;

  /// Report defect page title
  ///
  /// In en, this message translates to:
  /// **'Report Defect'**
  String get reportDefect;

  /// Defect reporting page content with item ID
  ///
  /// In en, this message translates to:
  /// **'Defect Reporting for Item: {itemId}'**
  String defectReportingForItem(String itemId);

  /// Offline sync page title
  ///
  /// In en, this message translates to:
  /// **'Offline Sync'**
  String get offlineSync;

  /// Error message when page is not found
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// Description for page not found error
  ///
  /// In en, this message translates to:
  /// **'The page you\'re looking for doesn\'t exist.'**
  String get pageNotFoundDescription;

  /// Button text to navigate to the dashboard
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get goToDashboard;

  /// Language selection subtitle
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get selectPreferredLanguage;

  /// Notification settings section title
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Daily PTI reminder toggle title
  ///
  /// In en, this message translates to:
  /// **'Daily PTI Reminder'**
  String get dailyPTIReminder;

  /// Daily reminder toggle description
  ///
  /// In en, this message translates to:
  /// **'Receive a daily reminder to perform your Pre-Trip Inspection'**
  String get dailyReminderDescription;

  /// Reminder time setting title
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// Test notification button text
  ///
  /// In en, this message translates to:
  /// **'Send Test Notification'**
  String get sendTestNotification;

  /// Test notification title
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// Test notification body text
  ///
  /// In en, this message translates to:
  /// **'This is a test notification from PTI Mobile App'**
  String get testNotificationBody;

  /// Test notification sent confirmation
  ///
  /// In en, this message translates to:
  /// **'Test notification sent!'**
  String get testNotificationSent;

  /// Preview section title
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Inspection reminder message
  ///
  /// In en, this message translates to:
  /// **'Time to perform your Pre-Trip Inspection'**
  String get timeToPerformInspection;

  /// Scheduled time message
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {time}'**
  String scheduledFor(String time);

  /// PWA notification instructions title
  ///
  /// In en, this message translates to:
  /// **'PWA Notification Instructions'**
  String get pwaNotificationInstructions;

  /// iOS PWA instructions header
  ///
  /// In en, this message translates to:
  /// **'For iOS PWA notifications to work properly:'**
  String get forIOSPWA;

  /// iOS PWA instruction step 1
  ///
  /// In en, this message translates to:
  /// **'1. Add this app to your home screen'**
  String get addAppToHomeScreen;

  /// iOS PWA instruction step 2
  ///
  /// In en, this message translates to:
  /// **'2. Open the app from the home screen icon'**
  String get openFromHomeScreen;

  /// iOS PWA instruction step 3
  ///
  /// In en, this message translates to:
  /// **'3. Allow notifications when prompted'**
  String get allowNotificationsWhenPrompted;

  /// iOS PWA instruction step 4
  ///
  /// In en, this message translates to:
  /// **'4. Notifications will appear daily until you complete an inspection'**
  String get notificationsAppearDaily;

  /// Android PWA instructions header
  ///
  /// In en, this message translates to:
  /// **'For Android PWA:'**
  String get forAndroidPWA;

  /// Android PWA instruction step 1
  ///
  /// In en, this message translates to:
  /// **'1. Add to home screen from browser menu'**
  String get addToHomeScreenFromBrowser;

  /// Android PWA instruction step 2
  ///
  /// In en, this message translates to:
  /// **'2. Open app from home screen'**
  String get openAppFromHomeScreen;

  /// Android PWA instruction step 3
  ///
  /// In en, this message translates to:
  /// **'3. Grant notification permissions'**
  String get grantNotificationPermissions;

  /// Dashboard quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Quick action subtitle for new inspection
  ///
  /// In en, this message translates to:
  /// **'Start pre-trip inspection'**
  String get startPreTripInspection;

  /// Quick action title for viewing reports
  ///
  /// In en, this message translates to:
  /// **'View Reports'**
  String get viewReports;

  /// Quick action subtitle for viewing reports
  ///
  /// In en, this message translates to:
  /// **'Previous inspections'**
  String get previousInspections;

  /// Quick action title for managing vehicles
  ///
  /// In en, this message translates to:
  /// **'Manage Vehicles'**
  String get manageVehicles;

  /// Quick action subtitle for managing vehicles
  ///
  /// In en, this message translates to:
  /// **'Add or edit vehicles'**
  String get addEditVehicles;

  /// Dashboard statistics section title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Statistics card title for total inspections
  ///
  /// In en, this message translates to:
  /// **'Total Inspections'**
  String get totalInspections;

  /// Statistics card title for monthly inspections
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// Statistics card title for active vehicles
  ///
  /// In en, this message translates to:
  /// **'Active Vehicles'**
  String get activeVehicles;

  /// Statistics card title for total vehicles
  ///
  /// In en, this message translates to:
  /// **'Total Vehicles'**
  String get totalVehicles;

  /// Dashboard recent activity section title
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// Message when there's no recent activity
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// Logout confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get logoutConfirmTitle;

  /// Confirmation message for logout dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// Success message when photos are updated
  ///
  /// In en, this message translates to:
  /// **'Photos updated!'**
  String get photosUpdated;

  /// Message showing number of photos attached
  ///
  /// In en, this message translates to:
  /// **'{count} photo{count, plural, =1{} other{s}} attached'**
  String photoAttached(int count);

  /// Error message when signature is required
  ///
  /// In en, this message translates to:
  /// **'Please provide your signature'**
  String get pleaseProvideSignature;

  /// Success message when inspection is completed
  ///
  /// In en, this message translates to:
  /// **'Inspection completed successfully!'**
  String get inspectionCompletedSuccessfully;

  /// Title for digital signature section
  ///
  /// In en, this message translates to:
  /// **'Digital Signature'**
  String get digitalSignature;

  /// Message for view reports feature placeholder
  ///
  /// In en, this message translates to:
  /// **'View Reports feature coming soon!'**
  String get viewReportsComingSoon;

  /// Message for vehicle management feature placeholder
  ///
  /// In en, this message translates to:
  /// **'Vehicle Management feature coming soon!'**
  String get vehicleManagementComingSoon;

  /// Message for data sync feature placeholder
  ///
  /// In en, this message translates to:
  /// **'Data Sync feature coming soon!'**
  String get dataSyncComingSoon;

  /// Button text to retry an action
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Title for inspection details page
  ///
  /// In en, this message translates to:
  /// **'Inspection Details'**
  String get inspectionDetails;

  /// Success message when PDF report is generated
  ///
  /// In en, this message translates to:
  /// **'PDF report generated successfully!'**
  String get pdfReportGenerated;

  /// Error message when PDF generation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to generate PDF'**
  String get failedToGeneratePdf;

  /// Title for report preview page
  ///
  /// In en, this message translates to:
  /// **'Report Preview'**
  String get reportPreview;

  /// Title for inspection report
  ///
  /// In en, this message translates to:
  /// **'Inspection Report'**
  String get inspectionReport;

  /// Button text to generate PDF report
  ///
  /// In en, this message translates to:
  /// **'Generate PDF Report'**
  String get generatePdfReport;

  /// Button text to go back to dashboard
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get backToDashboard;

  /// Success message when photo is captured
  ///
  /// In en, this message translates to:
  /// **'Photo captured successfully'**
  String get photoCapturedSuccessfully;

  /// Success message when photo is added from gallery
  ///
  /// In en, this message translates to:
  /// **'Photo added successfully'**
  String get photoAddedSuccessfully;

  /// Error message when photo capture fails
  ///
  /// In en, this message translates to:
  /// **'Failed to take photo'**
  String get failedToTakePhoto;

  /// Title for delete photo dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get deletePhoto;

  /// Confirmation message for deleting photo
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this photo?'**
  String get deletePhotoConfirmation;

  /// Success message when photo is deleted
  ///
  /// In en, this message translates to:
  /// **'Photo deleted'**
  String get photoDeleted;

  /// Title for photo documentation page
  ///
  /// In en, this message translates to:
  /// **'Photo Documentation'**
  String get photoDocumentation;

  /// Button text to select photo from gallery
  ///
  /// In en, this message translates to:
  /// **'From Gallery'**
  String get fromGallery;

  /// Button text to take the first photo
  ///
  /// In en, this message translates to:
  /// **'Take First Photo'**
  String get takeFirstPhoto;

  /// Message when no defects are found in report
  ///
  /// In en, this message translates to:
  /// **'No defects found.'**
  String get noDefectsFound;

  /// Title for pre-trip inspection report
  ///
  /// In en, this message translates to:
  /// **'Pre-Trip Inspection Report'**
  String get preTripInspectionReport;

  /// Message when no vehicles are available
  ///
  /// In en, this message translates to:
  /// **'Add vehicles to get started'**
  String get addVehiclesToStart;

  /// Message when search returns no results
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms'**
  String get tryAdjustingSearch;

  /// Button text to start an inspection with the type
  ///
  /// In en, this message translates to:
  /// **'Start {inspectionType}'**
  String startInspection(String inspectionType);

  /// Title for QR code scanning dialog
  ///
  /// In en, this message translates to:
  /// **'Scan Vehicle QR Code'**
  String get scanVehicleQRCode;

  /// Instructions for scanning QR codes
  ///
  /// In en, this message translates to:
  /// **'Position the QR code within the frame to scan'**
  String get scanInstructions;

  /// Message shown when no vehicles are available
  ///
  /// In en, this message translates to:
  /// **'No vehicles found'**
  String get noVehiclesFound;

  /// Placeholder text for vehicle search input
  ///
  /// In en, this message translates to:
  /// **'Search vehicles...'**
  String get searchVehicles;

  /// Button text for scanning QR codes
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCode;

  /// Label for inspection type selection
  ///
  /// In en, this message translates to:
  /// **'Inspection Type'**
  String get inspectionType;

  /// Display format for vehicle unit number
  ///
  /// In en, this message translates to:
  /// **'Unit #{unitNumber}'**
  String unitNumber(String unitNumber);

  /// Message shown when a vehicle is selected
  ///
  /// In en, this message translates to:
  /// **'Vehicle {unitNumber} selected'**
  String vehicleSelected(String unitNumber);

  /// Message shown when no vehicle is selected
  ///
  /// In en, this message translates to:
  /// **'Please select a vehicle to continue'**
  String get pleaseSelectVehicle;

  /// Error message when user is not found
  ///
  /// In en, this message translates to:
  /// **'User not found. Please check your credentials.'**
  String get userNotFound;

  /// Error message when inspection fails to start
  ///
  /// In en, this message translates to:
  /// **'Failed to start inspection: {error}'**
  String failedToStartInspection(String error);

  /// Inspection item name for fluid levels
  ///
  /// In en, this message translates to:
  /// **'Fluid Levels'**
  String get fluidLevels;

  /// Description for fluid levels inspection
  ///
  /// In en, this message translates to:
  /// **'Check engine oil, coolant, brake fluid, power steering fluid, and windshield washer fluid levels'**
  String get fluidLevelsDescription;

  /// Inspection item name for belts and hoses
  ///
  /// In en, this message translates to:
  /// **'Belts and Hoses'**
  String get beltsAndHoses;

  /// Description for belts and hoses inspection
  ///
  /// In en, this message translates to:
  /// **'Inspect belts for cracks, fraying, proper tension. Check hoses for leaks, cracks, or soft spots'**
  String get beltsAndHosesDescription;

  /// Inspection item name for components condition
  ///
  /// In en, this message translates to:
  /// **'Components and General Condition'**
  String get componentsCondition;

  /// Description for components condition inspection
  ///
  /// In en, this message translates to:
  /// **'Check battery, air filter, wiring, and overall engine compartment condition'**
  String get componentsConditionDescription;

  /// Inspection item name for safety equipment
  ///
  /// In en, this message translates to:
  /// **'Safety Equipment'**
  String get safetyEquipment;

  /// Description for safety equipment inspection
  ///
  /// In en, this message translates to:
  /// **'Fire extinguisher, emergency triangles, first aid kit, safety vest, seat belts'**
  String get safetyEquipmentDescription;

  /// Inspection item name for gauges and controls
  ///
  /// In en, this message translates to:
  /// **'Gauges and Controls'**
  String get gaugesAndControls;

  /// Description for gauges and controls inspection
  ///
  /// In en, this message translates to:
  /// **'Dashboard gauges, warning lights, switches, and control functionality'**
  String get gaugesAndControlsDescription;

  /// Inspection item name for brakes
  ///
  /// In en, this message translates to:
  /// **'Brakes'**
  String get brakes;

  /// Description for brakes inspection
  ///
  /// In en, this message translates to:
  /// **'Brake pedal feel, air pressure, parking brake, and brake system operation'**
  String get brakesDescription;

  /// Inspection item name for mirrors and windshield
  ///
  /// In en, this message translates to:
  /// **'Mirrors and Windshield'**
  String get mirrorsAndWindshield;

  /// Description for mirrors and windshield inspection
  ///
  /// In en, this message translates to:
  /// **'Mirror adjustment and condition, windshield condition, wipers, and washer operation'**
  String get mirrorsAndWindshieldDescription;

  /// Inspection item name for paperwork
  ///
  /// In en, this message translates to:
  /// **'Paperwork'**
  String get paperwork;

  /// Description for paperwork inspection
  ///
  /// In en, this message translates to:
  /// **'Vehicle registration, insurance documentation, previous inspection reports'**
  String get paperworkDescription;

  /// Inspection item name for lights and reflectors
  ///
  /// In en, this message translates to:
  /// **'Lights and Reflectors'**
  String get lightsAndReflectors;

  /// Description for lights and reflectors inspection
  ///
  /// In en, this message translates to:
  /// **'Headlights, taillights, turn signals, brake lights, hazard lights, and reflectors'**
  String get lightsAndReflectorsDescription;

  /// Inspection item name for tires
  ///
  /// In en, this message translates to:
  /// **'Tires'**
  String get tires;

  /// Description for tires inspection
  ///
  /// In en, this message translates to:
  /// **'Tread depth, tire pressure, sidewall condition, and overall tire condition'**
  String get tiresDescription;

  /// Inspection item name for wheels and rims
  ///
  /// In en, this message translates to:
  /// **'Wheels and Rims'**
  String get wheelsAndRims;

  /// Description for wheels and rims inspection
  ///
  /// In en, this message translates to:
  /// **'Wheel condition, lug nuts/bolts, and rim integrity'**
  String get wheelsAndRimsDescription;

  /// Inspection item name for suspension
  ///
  /// In en, this message translates to:
  /// **'Suspension'**
  String get suspension;

  /// Description for suspension inspection
  ///
  /// In en, this message translates to:
  /// **'Leaf springs, shock absorbers, air suspension, and mounting hardware'**
  String get suspensionDescription;

  /// Inspection item name for brake components
  ///
  /// In en, this message translates to:
  /// **'Brake Components'**
  String get brakeComponents;

  /// Description for brake components inspection
  ///
  /// In en, this message translates to:
  /// **'Brake chambers, lines, drums/rotors, and slack adjusters'**
  String get brakeComponentsDescription;

  /// Inspection item name for coupling system
  ///
  /// In en, this message translates to:
  /// **'Coupling System'**
  String get couplingSystem;

  /// Description for coupling system inspection
  ///
  /// In en, this message translates to:
  /// **'Fifth wheel, kingpin, safety chains, electrical connections, and air lines'**
  String get couplingSystemDescription;

  /// Inspection item name for trailer
  ///
  /// In en, this message translates to:
  /// **'Trailer'**
  String get trailer;

  /// Description for trailer inspection
  ///
  /// In en, this message translates to:
  /// **'Trailer condition, doors, cargo securement, and landing gear'**
  String get trailerDescription;

  /// Inspection item name for CDL license
  ///
  /// In en, this message translates to:
  /// **'CDL'**
  String get cdlLicense;

  /// Description for CDL license inspection
  ///
  /// In en, this message translates to:
  /// **'Commercial Driver\'s License validity, proper endorsements, and expiration date'**
  String get cdlLicenseDescription;

  /// Inspection item name for DOT medical card
  ///
  /// In en, this message translates to:
  /// **'DOT Medical Card'**
  String get dotMedicalCard;

  /// Description for DOT medical card inspection
  ///
  /// In en, this message translates to:
  /// **'Medical certificate validity and expiration date'**
  String get dotMedicalCardDescription;

  /// Category name for personal/driver documentation
  ///
  /// In en, this message translates to:
  /// **'Personal/Driver Docs'**
  String get personalDriverDocs;
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
      <String>['en', 'es', 'ru', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
