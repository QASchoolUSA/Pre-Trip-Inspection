import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

import '../../core/themes/app_theme.dart';
import '../../data/models/document_attachment.dart';

class DocumentViewer extends StatefulWidget {
  final DocumentAttachment document;

  const DocumentViewer({
    super.key,
    required this.document,
  });

  @override
  State<DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.fileName),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadDocument,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _openInExternalApp,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryBlue,
            ),
            SizedBox(height: 16),
            Text('Loading document...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _openInExternalApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Open in External App'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getDocumentIcon(),
            size: 80,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 24),
          Text(
            widget.document.fileName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Type: ${widget.document.type.name}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _downloadDocument,
                icon: const Icon(Icons.download),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _openInExternalApp,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon() {
    final extension = widget.document.fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _downloadDocument() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = Dio();
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${widget.document.fileName}';

      // For local files, just copy them
      if (widget.document.serverUrl != null) {
        await dio.download(widget.document.serverUrl!, filePath);
      } else {
        // Copy local file
        final sourceFile = File(widget.document.filePath);
        if (await sourceFile.exists()) {
          await sourceFile.copy(filePath);
        } else {
          throw 'Source file not found';
        }
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded to: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to download document: $e';
      });
    }
  }

  Future<void> _openInExternalApp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Uri uri;
      if (widget.document.serverUrl != null) {
        uri = Uri.parse(widget.document.serverUrl!);
      } else {
        // For local files, use file:// scheme
        uri = Uri.file(widget.document.filePath);
      }
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch document';
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to open document: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}