import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';

/// Upload Scan Screen for diabetic retinopathy analysis
/// Enables users to submit eye scan images with medical-grade file handling
class UploadScanScreen extends StatefulWidget {
  const UploadScanScreen({super.key});

  @override
  State<UploadScanScreen> createState() => _UploadScanScreenState();
}

class _UploadScanScreenState extends State<UploadScanScreen> {
  // File handling properties
  String? _selectedFilePath;
  Uint8List? _selectedFileBytes;
  String? _fileName;
  String? _fileExtension;
  bool _hasSelectedFile = false;

  // Supported file types
  static const List<String> _supportedExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar.scan(
        title: 'Upload Scan',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Title
              Text(
                'Upload Eye Scan',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Upload Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _selectFile,
                  icon: Icon(
                    Icons.upload_file,
                    color: colorScheme.onPrimary,
                    size: 18,
                  ),
                  label: Text(
                    'Select File',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // File Preview
              if (_hasSelectedFile) ...[
                _buildFilePreview(),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 16),

              // Analyze Report Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _hasSelectedFile ? _analyzeScan : null,
                  icon: Icon(
                    Icons.analytics,
                    color: colorScheme.onPrimary,
                    size: 18,
                  ),
                  label: Text(
                    'Analyze Report',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 200, // Fixed height to prevent overflow
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // File Icon or Image Preview
          if (_fileExtension == 'pdf') ...[
            Icon(
              Icons.picture_as_pdf,
              size: 28,
              color: Colors.red,
            ),
            const SizedBox(height: 6),
            Text(
              _fileName ?? 'PDF Document',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ] else if (_fileExtension != null &&
              ['jpg', 'jpeg', 'png'].contains(_fileExtension)) ...[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: kIsWeb && _selectedFileBytes != null
                    ? Image.memory(
                        _selectedFileBytes!,
                        fit: BoxFit.cover,
                      )
                    : !kIsWeb && _selectedFilePath != null
                        ? Image.file(
                            File(_selectedFilePath!),
                            fit: BoxFit.cover,
                          )
                        : Container(),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _fileName ?? 'Image File',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 10),

          // Remove File Button
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton.icon(
              onPressed: _removeFile,
              icon: Icon(
                Icons.delete_outline,
                color: colorScheme.error,
                size: 14,
              ),
              label: Text(
                'Remove File',
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _supportedExtensions,
        allowMultiple: false,
        withData: true,
        lockParentWindow: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final extension = file.extension?.toLowerCase();

        // Validate file extension
        if (extension == null || !_supportedExtensions.contains(extension)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Invalid file type. Please upload PDF, JPG, or PNG only.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        setState(() {
          // On web, use bytes instead of path
          if (kIsWeb) {
            _selectedFilePath = null;
            _selectedFileBytes = file.bytes;
          } else {
            _selectedFilePath = file.path;
            _selectedFileBytes = file.bytes;
          }
          _fileName = file.name;
          _fileExtension = extension;
          _hasSelectedFile = true;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selected: ${file.name}'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFilePath = null;
      _selectedFileBytes = null;
      _fileName = null;
      _fileExtension = null;
      _hasSelectedFile = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File removed'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _analyzeScan() {
    if (!_hasSelectedFile) return;

    // Create scan data to pass to processing screen
    final scanData = {
      'fileName': _fileName,
      'fileExtension': _fileExtension,
      'fileBytes': _selectedFileBytes,
      'filePath': _selectedFilePath,
    };

    // Navigate to processing screen with scan data
    Navigator.pushNamed(
      context,
      '/processing-screen',
      arguments: scanData,
    );
  }
}
