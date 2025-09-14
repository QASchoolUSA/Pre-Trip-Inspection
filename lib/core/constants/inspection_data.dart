import '../../data/models/inspection_models.dart';

/// Pre-defined inspection items for simplified PTI categories
class InspectionData {
  /// Engine Compartment Inspection Items
  static List<InspectionItem> get engineCompartmentItems => [
    InspectionItem(
      id: 'fluid_levels',
      name: 'Fluid Levels',
      description: 'Check engine oil, coolant, brake fluid, power steering fluid, and windshield washer fluid levels',
      category: 'Engine Compartment',
      isRequired: true,
    ),
    InspectionItem(
      id: 'belts_hoses',
      name: 'Belts and Hoses',
      description: 'Inspect belts for cracks, fraying, proper tension. Check hoses for leaks, cracks, or soft spots',
      category: 'Engine Compartment',
      isRequired: true,
    ),
    InspectionItem(
      id: 'components_condition',
      name: 'Components and General Condition',
      description: 'Check battery, air filter, wiring, and overall engine compartment condition',
      category: 'Engine Compartment',
      isRequired: true,
    ),
  ];
  /// Cab and Safety Equipment Inspection Items
  static List<InspectionItem> get cabSafetyItems => [
    InspectionItem(
      id: 'safety_equipment',
      name: 'Safety Equipment',
      description: 'Fire extinguisher, emergency triangles, first aid kit, safety vest, seat belts',
      category: 'Cab and Safety Equipment',
      isRequired: true,
    ),
    InspectionItem(
      id: 'gauges_controls',
      name: 'Gauges and Controls',
      description: 'Dashboard gauges, warning lights, switches, and control functionality',
      category: 'Cab and Safety Equipment',
      isRequired: true,
    ),
    InspectionItem(
      id: 'brakes',
      name: 'Brakes',
      description: 'Brake pedal feel, air pressure, parking brake, and brake system operation',
      category: 'Cab and Safety Equipment',
      isRequired: true,
    ),
    InspectionItem(
      id: 'mirrors_windshield',
      name: 'Mirrors and Windshield',
      description: 'Mirror adjustment and condition, windshield condition, wipers, and washer operation',
      category: 'Cab and Safety Equipment',
      isRequired: true,
    ),
    InspectionItem(
      id: 'paperwork',
      name: 'Paperwork',
      description: 'Vehicle registration, insurance documentation, previous inspection reports',
      category: 'Cab and Safety Equipment',
      isRequired: true,
    ),
  ];

  /// Exterior and Coupling System Inspection Items
  static List<InspectionItem> get exteriorCouplingItems => [
    InspectionItem(
      id: 'lights_reflectors',
      name: 'Lights and Reflectors',
      description: 'Headlights, taillights, turn signals, brake lights, hazard lights, and reflectors',
      category: 'Exterior and Coupling System',
      isRequired: true,
    ),
    InspectionItem(
      id: 'tires',
      name: 'Tires',
      description: 'Tread depth, tire pressure, sidewall condition, and overall tire condition',
      category: 'Exterior and Coupling System',
      isRequired: true,
    ),
    InspectionItem(
      id: 'wheels_rims',
      name: 'Wheels and Rims',
      description: 'Wheel condition, lug nuts/bolts, and rim integrity',
      category: 'Exterior and Coupling System',
      isRequired: true,
    ),
    InspectionItem(
      id: 'suspension',
      name: 'Suspension',
      description: 'Leaf springs, shock absorbers, air suspension, and mounting hardware',
      category: 'Exterior and Coupling System',
      isRequired: true,
    ),
    InspectionItem(
      id: 'brake_components',
      name: 'Brake Components',
      description: 'Brake chambers, lines, drums/rotors, and slack adjusters',
      category: 'Exterior and Coupling System',
      isRequired: true,
    ),
    InspectionItem(
      id: 'coupling_system',
      name: 'Coupling System',
      description: 'Fifth wheel, kingpin, safety chains, electrical connections, and air lines',
      category: 'Exterior and Coupling System',
      isRequired: true,
    ),
    InspectionItem(
      id: 'trailer',
      name: 'Trailer',
      description: 'Trailer condition, doors, cargo securement, and landing gear',
      category: 'Exterior and Coupling System',
      isRequired: true,
    ),
  ];

  /// Personal/Driver Documentation Items
  static List<InspectionItem> get personalDocsItems => [
    InspectionItem(
      id: 'cdl_license',
      name: 'CDL',
      description: 'Commercial Driver\'s License validity, proper endorsements, and expiration date',
      category: 'Personal/Driver Docs',
      isRequired: true,
    ),
    InspectionItem(
      id: 'dot_medical_card',
      name: 'DOT Medical Card',
      description: 'Medical certificate validity and expiration date',
      category: 'Personal/Driver Docs',
      isRequired: true,
    ),
  ];

  /// Get all inspection items for a complete pre-trip inspection
  static List<InspectionItem> getAllInspectionItems() {
    return [
      ...engineCompartmentItems,
      ...cabSafetyItems,
      ...exteriorCouplingItems,
      ...personalDocsItems,
    ];
  }

  /// Get inspection items by category
  static List<InspectionItem> getItemsByCategory(String category) {
    return getAllInspectionItems()
        .where((item) => item.category == category)
        .toList();
  }

  /// Get all unique categories
  static List<String> getAllCategories() {
    return getAllInspectionItems()
        .map((item) => item.category)
        .toSet()
        .toList()
        ..sort();
  }

  /// Get required items only
  static List<InspectionItem> getRequiredItems() {
    return getAllInspectionItems()
        .where((item) => item.isRequired)
        .toList();
  }

  /// Get optional items only
  static List<InspectionItem> getOptionalItems() {
    return getAllInspectionItems()
        .where((item) => !item.isRequired)
        .toList();
  }
}