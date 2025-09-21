import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/detailed_findings_card_widget.dart';
import './widgets/risk_assessment_display_widget.dart';
import './widgets/scan_image_preview_widget.dart';
import './widgets/share_report_button_widget.dart';

class DetailedReportScreen extends StatefulWidget {
  const DetailedReportScreen({Key? key}) : super(key: key);

  @override
  State<DetailedReportScreen> createState() => _DetailedReportScreenState();
}

class _DetailedReportScreenState extends State<DetailedReportScreen> {
  Map<String, dynamic>? scanData;
  bool _isLoading = false;
  bool _isSharing = false;
  Uint8List? _imageBytes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scanData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (scanData != null) {
      _loadScanImage();
    }
  }

  Future<void> _loadScanImage() async {
    if (scanData?['imageUrl'] == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final ref = FirebaseStorage.instance.refFromURL(scanData!['imageUrl']);
      final bytes = await ref.getData();

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading scan image: ${e.toString()}'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }

  Future<void> _shareReport() async {
    if (scanData == null) return;

    setState(() {
      _isSharing = true;
    });

    try {
      // Request storage permission on Android
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          if (mounted) {
            setState(() {
              _isSharing = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Storage permission is required to save the report'),
                backgroundColor: AppTheme.errorLight,
              ),
            );
          }
          return;
        }
      }

      final pdf = pw.Document();

      // Add scan image if available
      pw.ImageProvider? imageProvider;
      if (_imageBytes != null) {
        imageProvider = pw.MemoryImage(_imageBytes!);
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Diabetic Retinopathy Analysis Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Patient Information
              pw.Text(
                'Report Date: ${DateTime.parse(scanData!['uploadDate'].toDate().toString()).toString().split(' ')[0]}',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 20),

              // Scan Image
              if (imageProvider != null) ...[
                pw.Text(
                  'Retinal Scan Image:',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Container(
                    width: 300,
                    height: 200,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Image(imageProvider, fit: pw.BoxFit.contain),
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // Risk Assessment
              pw.Text(
                'Risk Assessment:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                      color: _getPdfRiskColor(scanData!['riskLevel'] ?? '')),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Risk Level: ${scanData!['riskLevel'] ?? 'Unknown'}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: _getPdfRiskColor(scanData!['riskLevel'] ?? ''),
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Confidence Score: ${((scanData!['confidenceScore'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Detailed Findings
              pw.Text(
                'Detailed Findings:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                _getDetailedExplanation(scanData!['riskLevel'] ?? ''),
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),

              // Medical Disclaimer
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'IMPORTANT MEDICAL DISCLAIMER',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red700,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'This AI-powered analysis is for screening purposes only and should not replace professional medical consultation. Please consult with a qualified ophthalmologist or healthcare provider for proper diagnosis and treatment recommendations.',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      final output = await getApplicationDocumentsDirectory();
      final fileName =
          'diabetic_retinopathy_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        setState(() {
          _isSharing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report saved to: ${file.path}'),
            backgroundColor: AppTheme.successLight,
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: ${e.toString()}'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }

  PdfColor _getPdfRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'mild':
      case 'low':
        return PdfColors.green;
      case 'moderate':
      case 'medium':
        return PdfColors.orange;
      case 'severe':
      case 'high':
        return PdfColors.red;
      default:
        return PdfColors.grey;
    }
  }

  String _getDetailedExplanation(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'mild':
      case 'low':
        return 'This scan indicates early or mild signs of diabetic retinopathy. Small areas of swelling and tiny blood vessel blockages may be present. Regular monitoring is recommended, typically every 6-12 months. Maintaining good blood sugar control and following your diabetes management plan is crucial.';
      case 'moderate':
      case 'medium':
        return 'This scan shows moderate diabetic retinopathy changes. Blood vessel damage is more pronounced, with potential bleeding and fluid leakage in the retina. It is recommended to consult with an ophthalmologist within 2-3 months for detailed evaluation and potential treatment options.';
      case 'severe':
      case 'high':
        return 'This scan indicates severe diabetic retinopathy with significant blood vessel damage and potential vision-threatening complications. Immediate medical attention from an ophthalmologist is strongly recommended. Treatment may include laser therapy, injections, or surgery to prevent further vision loss.';
      default:
        return 'The scan has been analyzed, but the risk level could not be determined clearly. Please consult with a healthcare professional for proper evaluation and guidance.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (scanData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detailed Report')),
        body: const Center(
          child: Text('No scan data available'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Detailed Report',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        backgroundColor: AppTheme.surfaceLight,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isSharing ? null : _shareReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scan Image Preview
            ScanImagePreviewWidget(
              imageBytes: _imageBytes,
              isLoading: _isLoading,
              onZoom: () {
                if (_imageBytes != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => _FullScreenImageViewer(
                        imageBytes: _imageBytes!,
                      ),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // Risk Assessment Display
            RiskAssessmentDisplayWidget(
              riskLevel: scanData!['riskLevel'] ?? 'Unknown',
              confidenceScore: scanData!['confidenceScore'] ?? 0.0,
              uploadDate: scanData!['uploadDate']?.toDate() ?? DateTime.now(),
            ),

            const SizedBox(height: 24),

            // Detailed Findings
            DetailedFindingsCardWidget(
              riskLevel: scanData!['riskLevel'] ?? 'Unknown',
              explanation:
                  _getDetailedExplanation(scanData!['riskLevel'] ?? ''),
            ),

            const SizedBox(height: 24),

            // Share/Download Button
            ShareReportButtonWidget(
              onPressed: _shareReport,
              isLoading: _isSharing,
            ),

            const SizedBox(height: 24),

            // Medical Disclaimer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorLight.withAlpha(26),
                border: Border.all(
                  color: AppTheme.errorLight.withAlpha(77),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IMPORTANT MEDICAL DISCLAIMER',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.errorLight,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This AI-powered analysis is for screening purposes only and should not replace professional medical consultation. Please consult with a qualified ophthalmologist or healthcare provider for proper diagnosis and treatment recommendations.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.onSurfaceVariantLight,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final Uint8List imageBytes;

  const _FullScreenImageViewer({required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Scan Image',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.memory(
            imageBytes,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
