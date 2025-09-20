/// Generated file. Do not edit.
///
/// This file contains the localization strings for the PTI Mobile App.
/// To add new strings, edit the ARB files in lib/l10n/ and run:
/// flutter gen-l10n

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'PTI Мобільний Додаток';

  @override
  String get welcome => 'Ласкаво просимо';

  @override
  String get login => 'Увійти';

  @override
  String get logout => 'Вийти';

  @override
  String get email => 'Електронна пошта';

  @override
  String get password => 'Пароль';

  @override
  String get forgotPassword => 'Забули пароль?';

  @override
  String get inspections => 'Інспекції';

  @override
  String get newInspection => 'Нова інспекція';

  @override
  String get preTrip => 'Передрейсова';

  @override
  String get postTrip => 'Післярейсова';

  @override
  String get annual => 'Річна';

  @override
  String get vehicleSelection => 'Вибір транспортного засобу';

  @override
  String get selectVehicle => 'Оберіть транспортний засіб';

  @override
  String get scanQrCode => 'Сканувати QR-код';

  @override
  String get manualEntry => 'Ручне введення';

  @override
  String get vehicleNumber => 'Номер транспортного засобу';

  @override
  String get licensePlate => 'Номерний знак';

  @override
  String get vin => 'VIN';

  @override
  String get status => 'Статус';

  @override
  String get pass => 'Пройдено';

  @override
  String get fail => 'Не пройдено';

  @override
  String get notApplicable => 'Н/З';

  @override
  String get pending => 'Очікування';

  @override
  String get completed => 'Завершено';

  @override
  String get inProgress => 'В процесі';

  @override
  String get cabAndSafetyEquipment => 'Кабіна та Обладнання Безпеки';

  @override
  String get exteriorAndCouplingSystem =>
      'Зовнішній Вигляд та Система З\'єднання';

  @override
  String get engineCompartment => 'Моторний Відсік';

  @override
  String get underVehicle => 'Під транспортним засобом';

  @override
  String get save => 'Зберегти';

  @override
  String get saveAndExit => 'Зберегти та вийти';

  @override
  String get cancel => 'Скасувати';

  @override
  String get continue_ => 'Продовжити';

  @override
  String get next => 'Далі';

  @override
  String get previous => 'Назад';

  @override
  String get complete => 'Завершити';

  @override
  String get notes => 'Нотатки';

  @override
  String get addNotes => 'Додати нотатки';

  @override
  String get notesAdded => 'Нотатки додано';

  @override
  String get photos => 'Фотографії';

  @override
  String get addPhoto => 'Додати фото';

  @override
  String get takePhoto => 'Зробити фото';

  @override
  String get selectFromGallery => 'Вибрати з галереї';

  @override
  String get signature => 'Підпис';

  @override
  String get addSignature => 'Додати підпис';

  @override
  String get clear => 'Очистити';

  @override
  String get defectSeverity => 'Серйозність дефекту';

  @override
  String get minor => 'Незначний';

  @override
  String get major => 'Значний';

  @override
  String get critical => 'Критичний';

  @override
  String get required => 'ОБОВ\'ЯЗКОВО';

  @override
  String get optional => 'Необов\'язково';

  @override
  String get language => 'Мова';

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
  String get driver => 'Водій';

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
  String get quickActions => 'Швидкі Дії';

  @override
  String get startPreTripInspection => 'Почати передрейсовий огляд';

  @override
  String get viewReports => 'Переглянути Звіти';

  @override
  String get previousInspections => 'Попередні огляди';

  @override
  String get manageVehicles => 'Керування Транспортом';

  @override
  String get addEditVehicles => 'Додати або редагувати транспорт';

  @override
  String get statistics => 'Статистика';

  @override
  String get totalInspections => 'Всього Оглядів';

  @override
  String get thisMonth => 'Цього Місяця';

  @override
  String get activeVehicles => 'Активний Транспорт';

  @override
  String get totalVehicles => 'Всього Транспорту';

  @override
  String get recentActivity => 'Недавня Активність';

  @override
  String get noRecentActivity => 'Немає недавньої активності';

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
  String documentAttached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count document$_temp0 attached';
  }

  @override
  String documentsAttachedToItem(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documents attached',
      one: '1 document attached',
      zero: 'No documents',
    );
    return '$_temp0';
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
      'Функція управління транспортними засобами незабаром буде доступна!';

  @override
  String get dataSyncComingSoon => 'Data Sync feature coming soon!';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get inspectionDetails => 'Inspection Details';

  @override
  String get pdfReportGenerated => 'PDF звіт успішно створено!';

  @override
  String get failedToGeneratePdf => 'Не вдалося створити PDF';

  @override
  String get reportPreview => 'Report Preview';

  @override
  String get inspectionReport => 'Inspection Report';

  @override
  String get generatePdfReport => 'Generate PDF Report';

  @override
  String get backToDashboard => 'Back to Dashboard';

  @override
  String get photoCapturedSuccessfully => 'Фото успішно зроблено';

  @override
  String get photoAddedSuccessfully => 'Фото успішно додано';

  @override
  String get failedToTakePhoto => 'Не вдалося зробити фото';

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
  String get preTripInspectionReport => 'Звіт передрейсового огляду';

  @override
  String get addVehiclesToStart => 'Додайте транспортні засоби для початку';

  @override
  String get tryAdjustingSearch =>
      'Спробуйте змінити пошук або додати транспортні засоби для початку.';

  @override
  String startInspection(String inspectionType) {
    return 'Почати $inspectionType';
  }

  @override
  String get scanVehicleQRCode => 'Сканувати QR-код Транспорту';

  @override
  String get scanInstructions => 'Розташуйте QR-код у рамці для сканування';

  @override
  String get noVehiclesFound => 'Транспортні засоби не знайдені';

  @override
  String get searchVehicles => 'Пошук транспортних засобів...';

  @override
  String get scanQRCode => 'Сканувати QR-код';

  @override
  String get inspectionType => 'Тип Огляду';

  @override
  String unitNumber(String unitNumber) {
    return 'Одиниця #$unitNumber';
  }

  @override
  String vehicleSelected(String unitNumber) {
    return 'Транспортний засіб $unitNumber вибрано';
  }

  @override
  String get pleaseSelectVehicle =>
      'Будь ласка, виберіть транспортний засіб для продовження';

  @override
  String get userNotFound =>
      'Користувача не знайдено. Будь ласка, перевірте ваші облікові дані.';

  @override
  String failedToStartInspection(String error) {
    return 'Не вдалося розпочати інспекцію: $error';
  }

  @override
  String get fluidLevels => 'Рівні рідин';

  @override
  String get fluidLevelsDescription =>
      'Перевірити рівні моторного масла, охолоджуючої рідини, гальмівної рідини, рідини гідропідсилювача керма та рідини склоомивача';

  @override
  String get beltsAndHoses => 'Ремені та Шланги';

  @override
  String get beltsAndHosesDescription =>
      'Оглянути ремені та шланги на предмет тріщин, зносу або пошкоджень';

  @override
  String get componentsCondition => 'Стан Компонентів';

  @override
  String get componentsConditionDescription =>
      'Перевірити загальний стан компонентів двигуна';

  @override
  String get safetyEquipment => 'Обладнання Безпеки';

  @override
  String get safetyEquipmentDescription =>
      'Перевірити вогнегасник, аварійні трикутники, аптечку першої допомоги';

  @override
  String get gaugesAndControls => 'Прилади та Управління';

  @override
  String get gaugesAndControlsDescription =>
      'Перевірити роботу всіх приладів та органів управління';

  @override
  String get brakes => 'Гальма';

  @override
  String get brakesDescription => 'Перевірити гальмівну систему та її роботу';

  @override
  String get mirrorsAndWindshield => 'Дзеркала та Лобове Скло';

  @override
  String get mirrorsAndWindshieldDescription =>
      'Перевірити дзеркала, лобове скло та склоочисники';

  @override
  String get paperwork => 'Документація';

  @override
  String get paperworkDescription =>
      'Перевірити реєстрацію транспортного засобу, страховку та необхідні документи';

  @override
  String get lightsAndReflectors => 'Фари та Відбивачі';

  @override
  String get lightsAndReflectorsDescription =>
      'Перевірити всі фари та відбивачі транспортного засобу';

  @override
  String get tires => 'Шини';

  @override
  String get tiresDescription =>
      'Оглянути шини на предмет зносу, пошкоджень та правильного тиску';

  @override
  String get wheelsAndRims => 'Колеса та Диски';

  @override
  String get wheelsAndRimsDescription =>
      'Перевірити колеса та диски на предмет тріщин або пошкоджень';

  @override
  String get suspension => 'Підвіска';

  @override
  String get suspensionDescription => 'Оглянути компоненти підвіски';

  @override
  String get brakeComponents => 'Компоненти Гальм';

  @override
  String get brakeComponentsDescription =>
      'Перевірити гальмівні магістралі, барабани та пов\'язані компоненти';

  @override
  String get couplingSystem => 'Система З\'єднання';

  @override
  String get couplingSystemDescription =>
      'Оглянути сідельно-зчіпний пристрій, шворень та з\'єднання';

  @override
  String get trailer => 'Причіп';

  @override
  String get trailerDescription =>
      'Перевірити загальний стан причепа, якщо він присутній';

  @override
  String get cdlLicense => 'Ліцензія CDL';

  @override
  String get cdlLicenseDescription =>
      'Перевірити дійсну комерційну водійську ліцензію';

  @override
  String get dotMedicalCard => 'Медична Карта DOT';

  @override
  String get dotMedicalCardDescription =>
      'Перевірити дійсний медичний сертифікат DOT';

  @override
  String get personalDriverDocs => 'Особисті/Водійські Документи';
}
