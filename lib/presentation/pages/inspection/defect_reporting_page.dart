import 'package:flutter/material.dart';

class DefectReportingPage extends StatelessWidget {
  final String inspectionId;
  final String itemId;
  
  const DefectReportingPage({
    super.key,
    required this.inspectionId,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Defect'),
      ),
      body: Center(
        child: Text('Defect Reporting for Item: $itemId'),
      ),
    );
  }
}