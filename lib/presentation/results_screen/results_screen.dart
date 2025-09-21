import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/custom_app_bar.dart';

/// Results Screen for displaying diabetic retinopathy analysis results
class ResultsScreen extends StatefulWidget {
  final Map<String, dynamic>? scanData;
  
  const ResultsScreen({super.key, this.scanData});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  // Use provided scan data or fall back to mock data
  late final Map<String, dynamic> _analysisData;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Get scan data from route arguments or use provided scan data
    WidgetsBinding.instance.addPostFrameCallback((_) {
			final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
			if (args != null) {
				setState(() {
					final dynamic cs = args['confidenceScore'];
					_analysisData = {
						'fileName': args['fileName'] ?? 'retinal_scan.jpg',
						'riskLevel': args['riskLevel'] ?? args['predictedClass'] ?? 'Unknown',
						'confidenceScore': cs is num ? cs : (cs == null ? null : double.tryParse('$cs')),
					};
				});
			}
    });
    
    _analysisData = widget.scanData ?? {
			"fileName": "retinal_scan_20250122.jpg",
			"riskLevel": "Unknown",
			"confidenceScore": 0.0,
    };
  }

  // Generate mock analysis results for demonstration
  Map<String, dynamic> _generateMockAnalysis(String fileName) {
    // Simulate different risk levels based on file name or random
    final riskLevels = ['Low', 'Mild', 'Moderate', 'High', 'Severe'];
    final random = DateTime.now().millisecondsSinceEpoch;
    final riskLevel = riskLevels[random % riskLevels.length];
    
    // Generate confidence score between 75-95%
    final confidenceScore = 75.0 + (random % 20);
    
    return {
      "fileName": fileName,
      "riskLevel": riskLevel,
      "confidenceScore": confidenceScore,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar.results(
        title: 'Analysis Results',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // File Preview
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  Icons.image,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                _analysisData['fileName'] as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Risk Level
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getRiskColor(_analysisData['riskLevel'] as String)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getRiskColor(_analysisData['riskLevel'] as String)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Risk Level',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _analysisData['riskLevel'] as String,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color:
                            _getRiskColor(_analysisData['riskLevel'] as String),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Confidence Score (shown only if available)
              if (_analysisData['confidenceScore'] != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Confidence Score',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_analysisData['confidenceScore']}%',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Save to History Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveToHistory,
                  icon: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.save,
                          color: colorScheme.onPrimary,
                          size: 20,
                        ),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save to History',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

	Color _getRiskColor(String riskLevel) {
		switch (riskLevel.toLowerCase()) {
			case 'no dr':
			case 'low':
				return Colors.green;
			case 'mild':
				return Colors.lightGreen;
			case 'moderate':
				return Colors.orange;
			case 'high':
			case 'severe':
				return Colors.red;
			case 'proliferative':
				return Colors.deepOrange;
			default:
				return Colors.grey;
		}
	}

  void _saveToHistory() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Save to Firestore under users/{uid}/history
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .add({
        'fileUrl': _analysisData['fileName'] ?? 'retinal_scan_20250122.jpg', // Use actual filename
        'riskLevel': _analysisData['riskLevel'],
        'confidence': _analysisData['confidenceScore'],
        'uploadDate': Timestamp.now(),
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report saved to history'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Navigate back to history screen to show the newly saved report
        Navigator.pushReplacementNamed(context, '/history-screen');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
