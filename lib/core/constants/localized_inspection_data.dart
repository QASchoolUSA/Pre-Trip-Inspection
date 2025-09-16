import 'package:flutter/material.dart';
import '../../data/models/inspection_models.dart';
import '../../generated/l10n/app_localizations.dart';

/// Localized inspection data that uses AppLocalizations for proper i18n support
class LocalizedInspectionData {
  /// Engine Compartment Inspection Items
  static List<InspectionItem> getEngineCompartmentItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      InspectionItem(
        id: 'fluid_levels',
        name: l10n.fluidLevels,
        description: l10n.fluidLevelsDescription,
        category: l10n.engineCompartment,
        isRequired: true,
      ),
      InspectionItem(
        id: 'belts_hoses',
        name: l10n.beltsAndHoses,
        description: l10n.beltsAndHosesDescription,
        category: l10n.engineCompartment,
        isRequired: true,
      ),
      InspectionItem(
        id: 'components_condition',
        name: l10n.componentsCondition,
        description: l10n.componentsConditionDescription,
        category: l10n.engineCompartment,
        isRequired: true,
      ),
    ];
  }

  /// Cab and Safety Equipment Inspection Items
  static List<InspectionItem> getCabSafetyItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      InspectionItem(
        id: 'safety_equipment',
        name: l10n.safetyEquipment,
        description: l10n.safetyEquipmentDescription,
        category: l10n.cabAndSafetyEquipment,
        isRequired: true,
      ),
      InspectionItem(
        id: 'gauges_controls',
        name: l10n.gaugesAndControls,
        description: l10n.gaugesAndControlsDescription,
        category: l10n.cabAndSafetyEquipment,
        isRequired: true,
      ),
      InspectionItem(
        id: 'brakes',
        name: l10n.brakes,
        description: l10n.brakesDescription,
        category: l10n.cabAndSafetyEquipment,
        isRequired: true,
      ),
      InspectionItem(
        id: 'mirrors_windshield',
        name: l10n.mirrorsAndWindshield,
        description: l10n.mirrorsAndWindshieldDescription,
        category: l10n.cabAndSafetyEquipment,
        isRequired: true,
      ),
      InspectionItem(
        id: 'paperwork',
        name: l10n.paperwork,
        description: l10n.paperworkDescription,
        category: l10n.cabAndSafetyEquipment,
        isRequired: true,
      ),
    ];
  }

  /// Exterior and Coupling System Inspection Items
  static List<InspectionItem> getExteriorCouplingItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      InspectionItem(
        id: 'lights_reflectors',
        name: l10n.lightsAndReflectors,
        description: l10n.lightsAndReflectorsDescription,
        category: l10n.exteriorAndCouplingSystem,
        isRequired: true,
      ),
      InspectionItem(
        id: 'tires',
        name: l10n.tires,
        description: l10n.tiresDescription,
        category: l10n.exteriorAndCouplingSystem,
        isRequired: true,
      ),
      InspectionItem(
        id: 'wheels_rims',
        name: l10n.wheelsAndRims,
        description: l10n.wheelsAndRimsDescription,
        category: l10n.exteriorAndCouplingSystem,
        isRequired: true,
      ),
      InspectionItem(
        id: 'suspension',
        name: l10n.suspension,
        description: l10n.suspensionDescription,
        category: l10n.exteriorAndCouplingSystem,
        isRequired: true,
      ),
      InspectionItem(
        id: 'brake_components',
        name: l10n.brakeComponents,
        description: l10n.brakeComponentsDescription,
        category: l10n.exteriorAndCouplingSystem,
        isRequired: true,
      ),
      InspectionItem(
        id: 'coupling_system',
        name: l10n.couplingSystem,
        description: l10n.couplingSystemDescription,
        category: l10n.exteriorAndCouplingSystem,
        isRequired: true,
      ),
      InspectionItem(
        id: 'trailer',
        name: l10n.trailer,
        description: l10n.trailerDescription,
        category: l10n.exteriorAndCouplingSystem,
        isRequired: true,
      ),
    ];
  }

  /// Personal/Driver Documentation Items
  static List<InspectionItem> getPersonalDocsItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      InspectionItem(
        id: 'cdl_license',
        name: l10n.cdlLicense,
        description: l10n.cdlLicenseDescription,
        category: l10n.personalDriverDocs,
        isRequired: true,
      ),
      InspectionItem(
        id: 'dot_medical_card',
        name: l10n.dotMedicalCard,
        description: l10n.dotMedicalCardDescription,
        category: l10n.personalDriverDocs,
        isRequired: true,
      ),
    ];
  }

  /// Get all inspection items for a complete pre-trip inspection
  static List<InspectionItem> getAllInspectionItems(BuildContext context) {
    return [
      ...getEngineCompartmentItems(context),
      ...getCabSafetyItems(context),
      ...getExteriorCouplingItems(context),
      ...getPersonalDocsItems(context),
    ];
  }

  /// Get inspection items by category
  static List<InspectionItem> getItemsByCategory(BuildContext context, String category) {
    return getAllInspectionItems(context)
        .where((item) => item.category == category)
        .toList();
  }

  /// Get all unique categories
  static List<String> getAllCategories(BuildContext context) {
    return getAllInspectionItems(context)
        .map((item) => item.category)
        .toSet()
        .toList()
        ..sort();
  }
}