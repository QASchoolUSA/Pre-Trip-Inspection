/// Generated file. Do not edit.
///
/// This file contains the localization strings for the PTI Mobile App.
/// To add new strings, edit the ARB files in lib/l10n/ and run:
/// flutter gen-l10n

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'PTI Plus';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get login => 'Войти';

  @override
  String get logout => 'Выйти';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get inspections => 'Инспекции';

  @override
  String get newInspection => 'Новая инспекция';

  @override
  String get preTrip => 'Предрейсовая';

  @override
  String get postTrip => 'Послерейсовая';

  @override
  String get annual => 'Годовая';

  @override
  String get vehicleSelection => 'Выбор транспортного средства';

  @override
  String get selectVehicle => 'Выберите транспортное средство';

  @override
  String get scanQrCode => 'Сканировать QR-код';

  @override
  String get manualEntry => 'Ручной ввод';

  @override
  String get vehicleNumber => 'Номер транспортного средства';

  @override
  String get licensePlate => 'Номерной знак';

  @override
  String get vin => 'VIN';

  @override
  String get status => 'Статус';

  @override
  String get pass => 'Пройдено';

  @override
  String get fail => 'Не пройдено';

  @override
  String get notApplicable => 'Н/П';

  @override
  String get pending => 'Ожидание';

  @override
  String get completed => 'Завершено';

  @override
  String get inProgress => 'В процессе';

  @override
  String get cabAndSafetyEquipment => 'Кабина и Оборудование Безопасности';

  @override
  String get exteriorAndCouplingSystem => 'Внешний Вид и Система Сцепки';

  @override
  String get engineCompartment => 'Моторный Отсек';

  @override
  String get underVehicle => 'Под транспортным средством';

  @override
  String get save => 'Сохранить';

  @override
  String get saveAndExit => 'Сохранить и выйти';

  @override
  String get cancel => 'Отмена';

  @override
  String get continue_ => 'Продолжить';

  @override
  String get next => 'Далее';

  @override
  String get previous => 'Назад';

  @override
  String get complete => 'Завершить';

  @override
  String get notes => 'Заметки';

  @override
  String get addNotes => 'Добавить заметки';

  @override
  String get notesAdded => 'Заметки добавлены';

  @override
  String get photos => 'Фотографии';

  @override
  String get addPhoto => 'Добавить фото';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get selectFromGallery => 'Выбрать из галереи';

  @override
  String get signature => 'Подпись';

  @override
  String get addSignature => 'Добавить подпись';

  @override
  String get clear => 'Очистить';

  @override
  String get defectSeverity => 'Серьезность дефекта';

  @override
  String get minor => 'Незначительный';

  @override
  String get major => 'Значительный';

  @override
  String get critical => 'Критический';

  @override
  String get required => 'ОБЯЗАТЕЛЬНО';

  @override
  String get optional => 'Необязательно';

  @override
  String get language => 'Язык';

  @override
  String get english => 'Английский';

  @override
  String get russian => 'Русский';

  @override
  String get ukrainian => 'Украинский';

  @override
  String get spanish => 'Испанский';

  @override
  String get settings => 'Настройки';

  @override
  String get appPreferences => 'Настройки приложения';

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
  String get driver => 'Водитель';

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
  String get quickActions => 'Быстрые Действия';

  @override
  String get startPreTripInspection => 'Начать предрейсовый осмотр';

  @override
  String get viewReports => 'Просмотр Отчетов';

  @override
  String get previousInspections => 'Предыдущие осмотры';

  @override
  String get manageVehicles => 'Управление Транспортом';

  @override
  String get addEditVehicles => 'Добавить или редактировать транспорт';

  @override
  String get statistics => 'Статистика';

  @override
  String get totalInspections => 'Всего Осмотров';

  @override
  String get thisMonth => 'В Этом Месяце';

  @override
  String get activeVehicles => 'Активный Транспорт';

  @override
  String get totalVehicles => 'Всего Транспорта';

  @override
  String get recentActivity => 'Недавняя Активность';

  @override
  String get noRecentActivity => 'Нет недавней активности';

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
      'Функция управления транспортными средствами скоро будет доступна!';

  @override
  String get dataSyncComingSoon => 'Data Sync feature coming soon!';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get inspectionDetails => 'Inspection Details';

  @override
  String get pdfReportGenerated => 'PDF отчет успешно создан!';

  @override
  String get failedToGeneratePdf => 'Не удалось создать PDF';

  @override
  String get reportPreview => 'Report Preview';

  @override
  String get inspectionReport => 'Inspection Report';

  @override
  String get generatePdfReport => 'Generate PDF Report';

  @override
  String get backToDashboard => 'Back to Dashboard';

  @override
  String get photoCapturedSuccessfully => 'Фото успешно сделано';

  @override
  String get photoAddedSuccessfully => 'Фото успешно добавлено';

  @override
  String get failedToTakePhoto => 'Не удалось сделать фото';

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
  String get preTripInspectionReport => 'Отчет предрейсового осмотра';

  @override
  String get addVehiclesToStart => 'Добавьте транспортные средства для начала';

  @override
  String get tryAdjustingSearch =>
      'Попробуйте изменить поиск или добавить транспортные средства для начала.';

  @override
  String startInspection(String inspectionType) {
    return 'Начать $inspectionType';
  }

  @override
  String get scanVehicleQRCode => 'Сканировать QR-код Транспорта';

  @override
  String get scanInstructions => 'Расположите QR-код в рамке для сканирования';

  @override
  String get noVehiclesFound => 'Транспортные средства не найдены';

  @override
  String get searchVehicles => 'Поиск транспортных средств...';

  @override
  String get scanQRCode => 'Сканировать QR-код';

  @override
  String get inspectionType => 'Тип Осмотра';

  @override
  String unitNumber(String unitNumber) {
    return 'Единица #$unitNumber';
  }

  @override
  String vehicleSelected(String unitNumber) {
    return 'Транспортное средство $unitNumber выбрано';
  }

  @override
  String get pleaseSelectVehicle =>
      'Пожалуйста, выберите транспортное средство для продолжения';

  @override
  String get userNotFound =>
      'Пользователь не найден. Пожалуйста, проверьте ваши учетные данные.';

  @override
  String failedToStartInspection(String error) {
    return 'Не удалось начать инспекцию: $error';
  }

  @override
  String get fluidLevels => 'Уровни жидкостей';

  @override
  String get fluidLevelsDescription =>
      'Проверить уровни моторного масла, охлаждающей жидкости, тормозной жидкости, жидкости гидроусилителя руля и жидкости омывателя ветрового стекла';

  @override
  String get beltsAndHoses => 'Ремни и Шланги';

  @override
  String get beltsAndHosesDescription =>
      'Осмотреть ремни и шланги на предмет трещин, износа или повреждений';

  @override
  String get componentsCondition => 'Состояние Компонентов';

  @override
  String get componentsConditionDescription =>
      'Проверить общее состояние компонентов двигателя';

  @override
  String get safetyEquipment => 'Оборудование Безопасности';

  @override
  String get safetyEquipmentDescription =>
      'Проверить огнетушитель, аварийные треугольники, аптечку первой помощи';

  @override
  String get gaugesAndControls => 'Приборы и Управление';

  @override
  String get gaugesAndControlsDescription =>
      'Проверить работу всех приборов и органов управления';

  @override
  String get brakes => 'Тормоза';

  @override
  String get brakesDescription => 'Проверить тормозную систему и её работу';

  @override
  String get mirrorsAndWindshield => 'Зеркала и Лобовое Стекло';

  @override
  String get mirrorsAndWindshieldDescription =>
      'Проверить зеркала, лобовое стекло и стеклоочистители';

  @override
  String get paperwork => 'Документация';

  @override
  String get paperworkDescription =>
      'Проверить регистрацию транспортного средства, страховку и необходимые документы';

  @override
  String get lightsAndReflectors => 'Фары и Отражатели';

  @override
  String get lightsAndReflectorsDescription =>
      'Проверить все фары и отражатели транспортного средства';

  @override
  String get tires => 'Шины';

  @override
  String get tiresDescription =>
      'Осмотреть шины на предмет износа, повреждений и правильного давления';

  @override
  String get wheelsAndRims => 'Колёса и Диски';

  @override
  String get wheelsAndRimsDescription =>
      'Проверить колёса и диски на предмет трещин или повреждений';

  @override
  String get suspension => 'Подвеска';

  @override
  String get suspensionDescription => 'Осмотреть компоненты подвески';

  @override
  String get brakeComponents => 'Компоненты Тормозов';

  @override
  String get brakeComponentsDescription =>
      'Проверить тормозные магистрали, барабаны и связанные компоненты';

  @override
  String get couplingSystem => 'Система Сцепки';

  @override
  String get couplingSystemDescription =>
      'Осмотреть седельно-сцепное устройство, шкворень и соединения';

  @override
  String get trailer => 'Прицеп';

  @override
  String get trailerDescription =>
      'Проверить общее состояние прицепа, если он присутствует';

  @override
  String get cdlLicense => 'Лицензия CDL';

  @override
  String get cdlLicenseDescription =>
      'Проверить действительную коммерческую водительскую лицензию';

  @override
  String get dotMedicalCard => 'Медицинская Карта DOT';

  @override
  String get dotMedicalCardDescription =>
      'Проверить действительный медицинский сертификат DOT';

  @override
  String get personalDriverDocs => 'Личные/Водительские Документы';
}
