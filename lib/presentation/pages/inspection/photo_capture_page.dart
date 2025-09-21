import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../generated/l10n/app_localizations.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';

/// Photo capture page for documenting defects
class PhotoCapturePage extends ConsumerStatefulWidget {
  final String inspectionId;
  final String itemId;
  final List<String> existingPhotos;
  
  const PhotoCapturePage({
    super.key,
    required this.inspectionId,
    required this.itemId,
    this.existingPhotos = const [],
  });

  @override
  ConsumerState<PhotoCapturePage> createState() => _PhotoCapturePageState();
}

class _PhotoCapturePageState extends ConsumerState<PhotoCapturePage> {
  final ImagePicker _picker = ImagePicker();
  List<String> _photoUrls = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _photoUrls = List.from(widget.existingPhotos);
  }

  Future<void> _takePhoto() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: (AppConstants.imageQuality * 100).round(),
      );

      if (photo != null) {
        final String savedPath = await _savePhoto(photo);
        setState(() {
          _photoUrls.add(savedPath);
          _isLoading = false;
        });
        
        await _updateInspectionItem();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.photoCapturedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.failedToTakePhoto}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: (AppConstants.imageQuality * 100).round(),
      );

      if (photo != null) {
        final String savedPath = await _savePhoto(photo);
        setState(() {
          _photoUrls.add(savedPath);
          _isLoading = false;
        });
        
        await _updateInspectionItem();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.photoAddedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select photo: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<String> _savePhoto(XFile photo) async {
    try {
      if (kIsWeb) {
        // For web, we'll store the data URL
        final bytes = await photo.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${_bytesToBase64(bytes)}';
        return base64String;
      } else {
        // For mobile, save to local directory
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${widget.inspectionId}_${widget.itemId}.jpg';
        final String filePath = '${appDir.path}/photos/$fileName';
        
        // Create photos directory if it doesn't exist
        final Directory photosDir = Directory('${appDir.path}/photos');
        if (!await photosDir.exists()) {
          await photosDir.create(recursive: true);
        }
        
        // Copy the file
        final File savedFile = await File(photo.path).copy(filePath);
        return savedFile.path;
      }
    } catch (e) {
      throw Exception('Failed to save photo: $e');
    }
  }

  String _bytesToBase64(Uint8List bytes) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    int pad = bytes.length % 3;
    String result = '';
    
    for (int i = 0; i < bytes.length; i += 3) {
      int b1 = bytes[i];
      int b2 = i + 1 < bytes.length ? bytes[i + 1] : 0;
      int b3 = i + 2 < bytes.length ? bytes[i + 2] : 0;
      
      int bitmap = (b1 << 16) | (b2 << 8) | b3;
      
      result += chars[(bitmap >> 18) & 63];
      result += chars[(bitmap >> 12) & 63];
      result += chars[(bitmap >> 6) & 63];
      result += chars[bitmap & 63];
    }
    
    if (pad == 1) {
      result = '${result.substring(0, result.length - 2)}==';
    } else if (pad == 2) {
      result = '${result.substring(0, result.length - 1)}=';
    }
    
    return result;
  }

  Future<void> _updateInspectionItem() async {
    try {
      final inspections = ref.read(enhancedInspectionsProvider);
      final inspection = inspections.firstWhere(
        (i) => i.id == widget.inspectionId,
      );
      
      final itemIndex = inspection.items.indexWhere(
        (item) => item.id == widget.itemId,
      );
      
      if (itemIndex != -1) {
        final updatedItem = inspection.items[itemIndex].copyWith(
          photoUrls: _photoUrls,
        );
        
        await ref.read(enhancedInspectionsProvider.notifier).updateInspectionItem(
          widget.inspectionId,
          updatedItem,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update inspection: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _deletePhoto(int index) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Remove the photo URL
              setState(() {
                _photoUrls.removeAt(index);
              });
              
              // Update the inspection item
              await _updateInspectionItem();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Photo deleted'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Documentation'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Return true to indicate changes
            child: const Text(
              'Done',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Photo capture instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppColors.infoBlue.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.infoBlue.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.infoBlue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Photo Documentation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.infoBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Take clear photos of any defects or issues. Photos help with DOT compliance and maintenance records.',
                        style: TextStyle(
                          color: AppColors.infoBlue.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _takePhoto,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppColors.white),
                            ),
                          )
                        : const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('From Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Photo count and done button
          if (_photoUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
              child: Row(
                children: [
                  Text(
                    '${_photoUrls.length} photo${_photoUrls.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_photoUrls.length > 3)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warningYellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Many photos',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.warningYellow,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: const Size(0, 32),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          
          // Photo grid
          Expanded(
            child: _photoUrls.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: _photoUrls.length,
                    itemBuilder: (context, index) {
                      return _buildPhotoCard(index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'No photos yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take photos to document any defects or issues',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _takePhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take First Photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(int index) {
    final photoUrl = _photoUrls[index];
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Photo image
          Positioned.fill(
            child: kIsWeb && photoUrl.startsWith('data:')
                ? Image.memory(
                    _base64ToBytes(photoUrl.split(',')[1]),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.grey200,
                        child: const Icon(
                          Icons.broken_image,
                          size: 32,
                          color: AppColors.grey500,
                        ),
                      );
                    },
                  )
                : !kIsWeb
                    ? Image.file(
                        File(photoUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.grey200,
                            child: const Icon(
                              Icons.broken_image,
                              size: 32,
                              color: AppColors.grey500,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.grey200,
                        child: const Icon(
                          Icons.image,
                          size: 32,
                          color: AppColors.grey500,
                        ),
                      ),
          ),
          
          // Delete button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _deletePhoto(index),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.delete,
                  size: 16,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          
          // Photo number
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Tap to view overlay
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _viewPhoto(index),
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Uint8List _base64ToBytes(String base64String) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    
    // Remove padding
    base64String = base64String.replaceAll('=', '');
    
    List<int> bytes = [];
    
    for (int i = 0; i < base64String.length; i += 4) {
      int b1 = chars.indexOf(base64String[i]);
      int b2 = i + 1 < base64String.length ? chars.indexOf(base64String[i + 1]) : 0;
      int b3 = i + 2 < base64String.length ? chars.indexOf(base64String[i + 2]) : 0;
      int b4 = i + 3 < base64String.length ? chars.indexOf(base64String[i + 3]) : 0;
      
      int bitmap = (b1 << 18) | (b2 << 12) | (b3 << 6) | b4;
      
      bytes.add((bitmap >> 16) & 255);
      if (i + 2 < base64String.length) bytes.add((bitmap >> 8) & 255);
      if (i + 3 < base64String.length) bytes.add(bitmap & 255);
    }
    
    return Uint8List.fromList(bytes);
  }

  void _viewPhoto(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoViewPage(
          photoUrl: _photoUrls[index],
          photoIndex: index,
          totalPhotos: _photoUrls.length,
        ),
      ),
    );
  }
}

/// Full-screen photo view page
class PhotoViewPage extends StatelessWidget {
  final String photoUrl;
  final int photoIndex;
  final int totalPhotos;
  
  const PhotoViewPage({
    super.key,
    required this.photoUrl,
    required this.photoIndex,
    required this.totalPhotos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black.withValues(alpha: 0.5),
        foregroundColor: AppColors.white,
        title: Text('Photo ${photoIndex + 1} of $totalPhotos'),
      ),
      body: Center(
        child: InteractiveViewer(
          child: kIsWeb && photoUrl.startsWith('data:')
              ? Image.memory(
                  _base64ToBytes(photoUrl.split(',')[1]),
                  fit: BoxFit.contain,
                )
              : !kIsWeb
                  ? Image.file(
                      File(photoUrl),
                      fit: BoxFit.contain,
                    )
                  : Container(
                      color: AppColors.grey800,
                      child: const Icon(
                        Icons.image,
                        size: 64,
                        color: AppColors.grey400,
                      ),
                    ),
        ),
      ),
    );
  }

  Uint8List _base64ToBytes(String base64String) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    
    base64String = base64String.replaceAll('=', '');
    
    List<int> bytes = [];
    
    for (int i = 0; i < base64String.length; i += 4) {
      int b1 = chars.indexOf(base64String[i]);
      int b2 = i + 1 < base64String.length ? chars.indexOf(base64String[i + 1]) : 0;
      int b3 = i + 2 < base64String.length ? chars.indexOf(base64String[i + 2]) : 0;
      int b4 = i + 3 < base64String.length ? chars.indexOf(base64String[i + 3]) : 0;
      
      int bitmap = (b1 << 18) | (b2 << 12) | (b3 << 6) | b4;
      
      bytes.add((bitmap >> 16) & 255);
      if (i + 2 < base64String.length) bytes.add((bitmap >> 8) & 255);
      if (i + 3 < base64String.length) bytes.add(bitmap & 255);
    }
    
    return Uint8List.fromList(bytes);
  }
}