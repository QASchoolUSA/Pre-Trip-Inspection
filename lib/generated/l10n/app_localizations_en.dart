/// Generated file. Do not edit.
///
/// This file contains the localization strings for the PTI Mobile App.
/// To add new strings, edit the ARB files in lib/l10n/ and run:
/// flutter gen-l10n

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PTI Plus';

  @override
  String get welcome => 'Welcome';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get inspections => 'Inspections';

  @override
  String get newInspection => 'New Inspection';

  @override
  String get preTrip => 'Pre-Trip';

  @override
  String get postTrip => 'Post-Trip';

  @override
  String get annual => 'Annual';

  @override
  String get vehicleSelection => 'Vehicle Selection';

  @override
  String get selectVehicle => 'Select Vehicle';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get manualEntry => 'Manual Entry';

  @override
  String get vehicleNumber => 'Vehicle Number';

  @override
  String get licensePlate => 'License Plate';

  @override
  String get vin => 'VIN';

  @override
  String get status => 'Status';

  @override
  String get pass => 'Pass';

  @override
  String get fail => 'Fail';

  @override
  String get notApplicable => 'N/A';

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Completed';

  @override
  String get inProgress => 'In Progress';

  @override
  String get cabAndSafetyEquipment => 'Cab and Safety Equipment';

  @override
  String get exteriorAndCouplingSystem => 'Exterior and Coupling System';

  @override
  String get engineCompartment => 'Engine Compartment';

  @override
  String get underVehicle => 'Under Vehicle';

  @override
  String get save => 'Save';

  @override
  String get saveAndExit => 'Save & Exit';

  @override
  String get cancel => 'Cancel';

  @override
  String get continue_ => 'Continue';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get complete => 'Complete';

  @override
  String get notes => 'Notes';

  @override
  String get addNotes => 'Add Notes';

  @override
  String get notesAdded => 'Notes Added';

  @override
  String get photos => 'Photos';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get selectFromGallery => 'Select from Gallery';

  @override
  String get signature => 'Signature';

  @override
  String get addSignature => 'Add Signature';

  @override
  String get clear => 'Clear';

  @override
  String get defectSeverity => 'Defect Severity';

  @override
  String get minor => 'Minor';

  @override
  String get major => 'Major';

  @override
  String get critical => 'Critical';

  @override
  String get required => 'REQUIRED';

  @override
  String get optional => 'Optional';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get russian => 'Russian';

  @override
  String get ukrainian => 'Ukrainian';

  @override
  String get spanish => 'Spanish';

  @override
  String get settings => 'Settings';

  @override
  String get appPreferences => 'App preferences';

  @override
  String get profile => 'Profile';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data available';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get location => 'Location';

  @override
  String get driver => 'Driver';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get report => 'Report';

  @override
  String get generateReport => 'Generate Report';

  @override
  String get downloadReport => 'Download Report';

  @override
  String get shareReport => 'Share Report';

  @override
  String get enterYourPin => 'Enter Your PIN';

  @override
  String get pinHint => '••••';

  @override
  String get searchVehicleHint => 'Search by unit number, make, model...';

  @override
  String get defectSeverityLabel => 'Defect Severity:';

  @override
  String photosAttachedToItem(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count photo$_temp0 attached to this item';
  }

  @override
  String get criticalDefectsFound => 'Critical Defects Found';

  @override
  String get criticalDefectsWarning =>
      'This vehicle has critical defects that may require immediate attention.';

  @override
  String get outOfService => 'Out of Service';

  @override
  String inspectionCompleted(int count) {
    return 'Inspection completed! All $count items finished ✓';
  }

  @override
  String itemsCompleted(int completed, int total) {
    return '$completed/$total items completed';
  }

  @override
  String photosAttached(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos attached',
      one: '1 photo attached',
      zero: 'No photos',
    );
    return '$_temp0';
  }

  @override
  String get inspection => 'Inspection';

  @override
  String get failed => 'Failed';

  @override
  String get ok => 'OK';

  @override
  String get overallNotes => 'Overall Notes (Optional)';

  @override
  String get overallNotesHint =>
      'Add any overall notes about this inspection...';

  @override
  String get driverSignature => 'Driver Signature';

  @override
  String get signatureInstruction =>
      'Please sign below to certify that you have completed this inspection.';

  @override
  String get certification => 'Certification';

  @override
  String get certificationText =>
      'By signing below, I certify that I have completed this pre-trip inspection in accordance with DOT regulations and that all defects have been properly documented.';

  @override
  String get backToInspection => 'Back to Inspection';

  @override
  String get completeInspection => 'Complete Inspection';

  @override
  String get help => 'Help';

  @override
  String get helpPageContent => 'Help Page';

  @override
  String get offlineSyncPageContent => 'Offline Sync Page';

  @override
  String get reportDefect => 'Report Defect';

  @override
  String defectReportingForItem(String itemId) {
    return 'Defect Reporting for Item: $itemId';
  }

  @override
  String get offlineSync => 'Offline Sync';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get pageNotFoundDescription =>
      'The page you\'re looking for doesn\'t exist.';

  @override
  String get goToDashboard => 'Go to Dashboard';

  @override
  String get selectPreferredLanguage => 'Select your preferred language';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get dailyPTIReminder => 'Daily PTI Reminder';

  @override
  String get dailyReminderDescription =>
      'Receive a daily reminder to perform your Pre-Trip Inspection';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get sendTestNotification => 'Send Test Notification';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get testNotificationBody =>
      'This is a test notification from PTI Plus';

  @override
  String get testNotificationSent => 'Test notification sent!';

  @override
  String get preview => 'Preview';

  @override
  String get timeToPerformInspection => 'It\'s time for your PTI!';

  @override
  String scheduledFor(String time) {
    return 'Scheduled for $time';
  }

  @override
  String get pwaNotificationInstructions => 'PWA Notification Instructions';

  @override
  String get forIOSPWA => 'For iOS PWA notifications to work properly:';

  @override
  String get addAppToHomeScreen => '1. Add this app to your home screen';

  @override
  String get openFromHomeScreen => '2. Open the app from the home screen icon';

  @override
  String get allowNotificationsWhenPrompted =>
      '3. Allow notifications when prompted';

  @override
  String get notificationsAppearDaily =>
      '4. Notifications will appear daily until you complete an inspection';

  @override
  String get forAndroidPWA => 'For Android PWA:';

  @override
  String get addToHomeScreenFromBrowser =>
      '1. Add to home screen from browser menu';

  @override
  String get openAppFromHomeScreen => '2. Open app from home screen';

  @override
  String get grantNotificationPermissions =>
      '3. Grant notification permissions';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get startPreTripInspection => 'Start pre-trip inspection';

  @override
  String get viewReports => 'View Reports';

  @override
  String get previousInspections => 'Previous inspections';

  @override
  String get manageVehicles => 'Manage Vehicles';

  @override
  String get addEditVehicles => 'Add or edit vehicles';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalInspections => 'Total Inspections';

  @override
  String get thisMonth => 'This Month';

  @override
  String get activeVehicles => 'Active Vehicles';

  @override
  String get totalVehicles => 'Total Vehicles';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String get logoutConfirmTitle => 'Confirm Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to logout?';

  @override
  String get photosUpdated => 'Photos updated!';

  @override
  String photoAttached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count photo$_temp0 attached';
  }

  @override
  String get pleaseProvideSignature => 'Please provide your signature';

  @override
  String get inspectionCompletedSuccessfully =>
      'Inspection completed successfully!';

  @override
  String get digitalSignature => 'Digital Signature';

  @override
  String get viewReportsComingSoon => 'View Reports feature coming soon!';

  @override
  String get vehicleManagementComingSoon =>
      'Vehicle Management feature coming soon!';

  @override
  String get dataSyncComingSoon => 'Data Sync feature coming soon!';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get inspectionDetails => 'Inspection Details';

  @override
  String get pdfReportGenerated => 'PDF report generated successfully!';

  @override
  String get failedToGeneratePdf => 'Failed to generate PDF';

  @override
  String get reportPreview => 'Report Preview';

  @override
  String get inspectionReport => 'Inspection Report';

  @override
  String get generatePdfReport => 'Generate PDF Report';

  @override
  String get backToDashboard => 'Back to Dashboard';

  @override
  String get photoCapturedSuccessfully => 'Photo captured successfully';

  @override
  String get photoAddedSuccessfully => 'Photo added successfully';

  @override
  String get failedToTakePhoto => 'Failed to take photo';

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get deletePhotoConfirmation =>
      'Are you sure you want to delete this photo?';

  @override
  String get photoDeleted => 'Photo deleted';

  @override
  String get photoDocumentation => 'Photo Documentation';

  @override
  String get fromGallery => 'From Gallery';

  @override
  String get takeFirstPhoto => 'Take First Photo';

  @override
  String get noDefectsFound => 'No defects found.';

  @override
  String get preTripInspectionReport => 'Pre-Trip Inspection Report';

  @override
  String get addVehiclesToStart => 'Add vehicles to get started';

  @override
  String get tryAdjustingSearch => 'Try adjusting your search terms';

  @override
  String startInspection(String inspectionType) {
    return 'Start $inspectionType';
  }

  @override
  String get scanVehicleQRCode => 'Scan Vehicle QR Code';

  @override
  String get scanInstructions =>
      'Position the QR code within the frame to scan';

  @override
  String get noVehiclesFound => 'No vehicles found';

  @override
  String get searchVehicles => 'Search vehicles...';

  @override
  String get scanQRCode => 'Scan QR Code';

  @override
  String get inspectionType => 'Inspection Type';

  @override
  String unitNumber(String unitNumber) {
    return 'Unit #$unitNumber';
  }

  @override
  String vehicleSelected(String unitNumber) {
    return 'Vehicle $unitNumber selected';
  }

  @override
  String get pleaseSelectVehicle => 'Please select a vehicle to continue';

  @override
  String get userNotFound => 'User not found. Please check your credentials.';

  @override
  String failedToStartInspection(String error) {
    return 'Failed to start inspection: $error';
  }

  @override
  String get fluidLevels => 'Fluid Levels';

  @override
  String get fluidLevelsDescription =>
      'Check engine oil, coolant, brake fluid, power steering fluid, and windshield washer fluid levels';

  @override
  String get beltsAndHoses => 'Belts and Hoses';

  @override
  String get beltsAndHosesDescription =>
      'Inspect belts for cracks, fraying, proper tension. Check hoses for leaks, cracks, or soft spots';

  @override
  String get componentsCondition => 'Components and General Condition';

  @override
  String get componentsConditionDescription =>
      'Check battery, air filter, wiring, and overall engine compartment condition';

  @override
  String get safetyEquipment => 'Safety Equipment';

  @override
  String get safetyEquipmentDescription =>
      'Fire extinguisher, emergency triangles, first aid kit, safety vest, seat belts';

  @override
  String get gaugesAndControls => 'Gauges and Controls';

  @override
  String get gaugesAndControlsDescription =>
      'Dashboard gauges, warning lights, switches, and control functionality';

  @override
  String get brakes => 'Brakes';

  @override
  String get brakesDescription =>
      'Brake pedal feel, air pressure, parking brake, and brake system operation';

  @override
  String get mirrorsAndWindshield => 'Mirrors and Windshield';

  @override
  String get mirrorsAndWindshieldDescription =>
      'Mirror adjustment and condition, windshield condition, wipers, and washer operation';

  @override
  String get paperwork => 'Paperwork';

  @override
  String get paperworkDescription =>
      'Vehicle registration, insurance documentation, previous inspection reports';

  @override
  String get lightsAndReflectors => 'Lights and Reflectors';

  @override
  String get lightsAndReflectorsDescription =>
      'Headlights, taillights, turn signals, brake lights, hazard lights, and reflectors';

  @override
  String get tires => 'Tires';

  @override
  String get tiresDescription =>
      'Tread depth, tire pressure, sidewall condition, and overall tire condition';

  @override
  String get wheelsAndRims => 'Wheels and Rims';

  @override
  String get wheelsAndRimsDescription =>
      'Wheel condition, lug nuts/bolts, and rim integrity';

  @override
  String get suspension => 'Suspension';

  @override
  String get suspensionDescription =>
      'Leaf springs, shock absorbers, air suspension, and mounting hardware';

  @override
  String get brakeComponents => 'Brake Components';

  @override
  String get brakeComponentsDescription =>
      'Brake chambers, lines, drums/rotors, and slack adjusters';

  @override
  String get couplingSystem => 'Coupling System';

  @override
  String get couplingSystemDescription =>
      'Fifth wheel, kingpin, safety chains, electrical connections, and air lines';

  @override
  String get trailer => 'Trailer';

  @override
  String get trailerDescription =>
      'Trailer condition, doors, cargo securement, and landing gear';

  @override
  String get cdlLicense => 'CDL';

  @override
  String get cdlLicenseDescription =>
      'Commercial Driver\'s License validity, proper endorsements, and expiration date';

  @override
  String get dotMedicalCard => 'DOT Medical Card';

  @override
  String get dotMedicalCardDescription =>
      'Medical certificate validity and expiration date';

  @override
  String get personalDriverDocs => 'Personal/Driver Docs';
}
