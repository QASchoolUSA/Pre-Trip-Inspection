import 'package:flutter/material.dart';

class InspectionDetailsPage extends StatelessWidget {
  final String inspectionId;
  
  const InspectionDetailsPage({super.key, required this.inspectionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection Details'),
      ),
      body: Center(
        child: Text('Inspection Details for ID: $inspectionId'),
      ),
    );
  }
}