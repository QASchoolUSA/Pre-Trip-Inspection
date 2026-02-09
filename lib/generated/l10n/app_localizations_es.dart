/// Generated file. Do not edit.
///
/// This file contains the localization strings for the PTI Mobile App.
/// To add new strings, edit the ARB files in lib/l10n/ and run:
/// flutter gen-l10n

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PTI Plus';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get inspections => 'Inspecciones';

  @override
  String get newInspection => 'Nueva inspección';

  @override
  String get preTrip => 'Pre-viaje';

  @override
  String get postTrip => 'Post-viaje';

  @override
  String get annual => 'Anual';

  @override
  String get vehicleSelection => 'Selección de vehículo';

  @override
  String get selectVehicle => 'Seleccionar vehículo';

  @override
  String get scanQrCode => 'Escanear código QR';

  @override
  String get manualEntry => 'Entrada manual';

  @override
  String get vehicleNumber => 'Número de vehículo';

  @override
  String get licensePlate => 'Placa de matrícula';

  @override
  String get vin => 'VIN';

  @override
  String get status => 'Estado';

  @override
  String get pass => 'Aprobado';

  @override
  String get fail => 'Reprobado';

  @override
  String get notApplicable => 'N/A';

  @override
  String get pending => 'Pendiente';

  @override
  String get completed => 'Completado';

  @override
  String get inProgress => 'En progreso';

  @override
  String get cabAndSafetyEquipment => 'Cabina y Equipo de Seguridad';

  @override
  String get exteriorAndCouplingSystem => 'Exterior y Sistema de Acoplamiento';

  @override
  String get engineCompartment => 'Compartimento del Motor';

  @override
  String get underVehicle => 'Debajo del vehículo';

  @override
  String get save => 'Guardar';

  @override
  String get saveAndExit => 'Guardar y salir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get continue_ => 'Continuar';

  @override
  String get next => 'Siguiente';

  @override
  String get previous => 'Anterior';

  @override
  String get complete => 'Completar';

  @override
  String get notes => 'Notas';

  @override
  String get addNotes => 'Agregar notas';

  @override
  String get notesAdded => 'Notas agregadas';

  @override
  String get photos => 'Fotos';

  @override
  String get addPhoto => 'Agregar foto';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get selectFromGallery => 'Seleccionar de galería';

  @override
  String get signature => 'Firma';

  @override
  String get addSignature => 'Agregar firma';

  @override
  String get clear => 'Limpiar';

  @override
  String get defectSeverity => 'Severidad del defecto';

  @override
  String get minor => 'Menor';

  @override
  String get major => 'Mayor';

  @override
  String get critical => 'Crítico';

  @override
  String get required => 'REQUERIDO';

  @override
  String get optional => 'Opcional';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get russian => 'Ruso';

  @override
  String get ukrainian => 'Ucraniano';

  @override
  String get spanish => 'Español';

  @override
  String get settings => 'Configuración';

  @override
  String get appPreferences => 'Preferencias de la aplicación';

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
  String get driver => 'Conductor';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get addVehicle => 'Add Vehicle';

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
  String get quickActions => 'Acciones Rápidas';

  @override
  String get startPreTripInspection => 'Iniciar inspección previa al viaje';

  @override
  String get viewReports => 'Ver Reportes';

  @override
  String get previousInspections => 'Inspecciones anteriores';

  @override
  String get manageVehicles => 'Gestionar Vehículos';

  @override
  String get addEditVehicles => 'Agregar o editar vehículos';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get totalInspections => 'Inspecciones Totales';

  @override
  String get thisMonth => 'Este Mes';

  @override
  String get activeVehicles => 'Vehículos Activos';

  @override
  String get totalVehicles => 'Vehículos Totales';

  @override
  String get recentActivity => 'Actividad Reciente';

  @override
  String get noRecentActivity => 'No hay actividad reciente';

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
      '¡La función de Gestión de Vehículos estará disponible pronto!';

  @override
  String get dataSyncComingSoon => 'Data Sync feature coming soon!';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get inspectionDetails => 'Inspection Details';

  @override
  String get pdfReportGenerated => '¡Reporte PDF generado exitosamente!';

  @override
  String get failedToGeneratePdf => 'Error al generar PDF';

  @override
  String get reportPreview => 'Report Preview';

  @override
  String get inspectionReport => 'Inspection Report';

  @override
  String get generatePdfReport => 'Generate PDF Report';

  @override
  String get backToDashboard => 'Back to Dashboard';

  @override
  String get photoCapturedSuccessfully => 'Foto capturada exitosamente';

  @override
  String get photoAddedSuccessfully => 'Foto agregada exitosamente';

  @override
  String get failedToTakePhoto => 'Error al tomar la foto';

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
  String get preTripInspectionReport => 'Reporte de Inspección Pre-Viaje';

  @override
  String get addVehiclesToStart => 'Agregar vehículos para comenzar';

  @override
  String get tryAdjustingSearch =>
      'Intenta ajustar tu búsqueda o agregar vehículos para comenzar.';

  @override
  String startInspection(String inspectionType) {
    return 'Iniciar $inspectionType';
  }

  @override
  String get scanVehicleQRCode => 'Escanear Código QR del Vehículo';

  @override
  String get scanInstructions =>
      'Posiciona el código QR dentro del marco para escanear';

  @override
  String get noVehiclesFound => 'No se encontraron vehículos';

  @override
  String get searchVehicles => 'Buscar vehículos...';

  @override
  String get scanQRCode => 'Escanear Código QR';

  @override
  String get inspectionType => 'Tipo de Inspección';

  @override
  String unitNumber(String unitNumber) {
    return 'Unidad #$unitNumber';
  }

  @override
  String vehicleSelected(String unitNumber) {
    return 'Vehículo $unitNumber seleccionado';
  }

  @override
  String get pleaseSelectVehicle =>
      'Por favor selecciona un vehículo para continuar';

  @override
  String get userNotFound =>
      'Usuario no encontrado. Por favor verifica tus credenciales.';

  @override
  String failedToStartInspection(String error) {
    return 'Error al iniciar la inspección: $error';
  }

  @override
  String get fluidLevels => 'Niveles de fluidos';

  @override
  String get fluidLevelsDescription =>
      'Verificar niveles de aceite del motor, refrigerante, líquido de frenos, líquido de dirección asistida y líquido limpiaparabrisas';

  @override
  String get beltsAndHoses => 'Correas y Mangueras';

  @override
  String get beltsAndHosesDescription =>
      'Inspeccionar correas y mangueras en busca de grietas, desgaste o daños';

  @override
  String get componentsCondition => 'Condición de Componentes';

  @override
  String get componentsConditionDescription =>
      'Verificar la condición general de los componentes del motor';

  @override
  String get safetyEquipment => 'Equipo de Seguridad';

  @override
  String get safetyEquipmentDescription =>
      'Verificar extintor, triángulos de emergencia, kit de primeros auxilios';

  @override
  String get gaugesAndControls => 'Medidores y Controles';

  @override
  String get gaugesAndControlsDescription =>
      'Verificar el funcionamiento de todos los medidores y controles';

  @override
  String get brakes => 'Frenos';

  @override
  String get brakesDescription =>
      'Probar el sistema de frenos y verificar su funcionamiento';

  @override
  String get mirrorsAndWindshield => 'Espejos y Parabrisas';

  @override
  String get mirrorsAndWindshieldDescription =>
      'Verificar espejos, parabrisas y limpiaparabrisas';

  @override
  String get paperwork => 'Documentación';

  @override
  String get paperworkDescription =>
      'Verificar registro del vehículo, seguro y documentos requeridos';

  @override
  String get lightsAndReflectors => 'Luces y Reflectores';

  @override
  String get lightsAndReflectorsDescription =>
      'Verificar todas las luces y reflectores del vehículo';

  @override
  String get tires => 'Neumáticos';

  @override
  String get tiresDescription =>
      'Inspeccionar neumáticos en busca de desgaste, daños y presión adecuada';

  @override
  String get wheelsAndRims => 'Ruedas y Llantas';

  @override
  String get wheelsAndRimsDescription =>
      'Verificar ruedas y llantas en busca de grietas o daños';

  @override
  String get suspension => 'Suspensión';

  @override
  String get suspensionDescription =>
      'Inspeccionar componentes de la suspensión';

  @override
  String get brakeComponents => 'Componentes de Frenos';

  @override
  String get brakeComponentsDescription =>
      'Verificar líneas de freno, tambores y componentes relacionados';

  @override
  String get couplingSystem => 'Sistema de Acoplamiento';

  @override
  String get couplingSystemDescription =>
      'Inspeccionar quinta rueda, perno rey y conexiones';

  @override
  String get trailer => 'Remolque';

  @override
  String get trailerDescription =>
      'Verificar condición general del remolque si está presente';

  @override
  String get cdlLicense => 'Licencia CDL';

  @override
  String get cdlLicenseDescription =>
      'Verificar licencia de conducir comercial válida';

  @override
  String get dotMedicalCard => 'Tarjeta Médica DOT';

  @override
  String get dotMedicalCardDescription =>
      'Verificar certificado médico DOT válido';

  @override
  String get personalDriverDocs => 'Documentos Personales/Conductor';
}
