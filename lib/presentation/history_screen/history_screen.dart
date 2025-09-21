import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/app_export.dart';
import './widgets/empty_history_widget.dart';
import './widgets/export_button_widget.dart';
import './widgets/scan_history_card_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _isExporting = false;
  List<DocumentSnapshot> _scanHistory = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadScanHistory();
  }

  Future<void> _loadScanHistory() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('history')
            .orderBy('uploadDate', descending: true)
            .get();

        if (mounted) {
          setState(() {
            _scanHistory = querySnapshot.docs;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading scan history: ${e.toString()}'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }

  Future<void> _refreshHistory() async {
    await _loadScanHistory();
  }

  Future<void> _exportHistory() async {
    if (_scanHistory.isEmpty) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                  level: 0,
                  child: pw.Text('Diabetic Retinopathy Scan History')),
              pw.SizedBox(height: 20),
              pw.Text(
                  'Generated on: ${DateTime.now().toString().split('.')[0]}'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Date', 'Risk Level', 'Confidence Score'],
                data: _scanHistory.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final uploadDate =
                      (data['uploadDate'] as Timestamp?)?.toDate();
                  final riskLevel = data['riskLevel'] ?? 'Unknown';
                  final confidence = data['confidence'] ?? 0.0;

                  return [
                    uploadDate?.toString().split(' ')[0] ?? 'Unknown',
                    riskLevel,
                    '${confidence.toStringAsFixed(1)}%'
                  ];
                }).toList(),
              ),
            ];
          },
        ),
      );

      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/diabetic_retinopathy_history.pdf');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        setState(() {
          _isExporting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('History exported to: ${file.path}'),
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
          _isExporting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting history: ${e.toString()}'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }

  List<DocumentSnapshot> get _filteredHistory {
    if (_searchQuery.isEmpty) {
      return _scanHistory;
    }

    return _scanHistory.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final riskLevel = (data['riskLevel'] ?? '').toString().toLowerCase();
      final uploadDate = (data['uploadDate'] as Timestamp?)?.toDate();
      final dateString = uploadDate?.toString().toLowerCase() ?? '';

      return riskLevel.contains(_searchQuery.toLowerCase()) ||
          dateString.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Scan History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        backgroundColor: AppTheme.surfaceLight,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ScanHistorySearchDelegate(_scanHistory),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by date or risk level...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.outlineLight),
                ),
                filled: true,
                fillColor: AppTheme.surfaceVariantLight,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Export Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ExportButtonWidget(
              onPressed: _exportHistory,
              isLoading: _isExporting,
              historyCount: _scanHistory.length,
            ),
          ),

          const SizedBox(height: 16),

          // History List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
                    ),
                  )
                : _filteredHistory.isEmpty
                    ? _searchQuery.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: AppTheme.secondaryLight.withAlpha(128),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results found for "$_searchQuery"',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppTheme.secondaryLight,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : const EmptyHistoryWidget()
                    : RefreshIndicator(
                        onRefresh: _refreshHistory,
                        color: AppTheme.primaryLight,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _filteredHistory.length,
                          itemBuilder: (context, index) {
                            final doc = _filteredHistory[index];
                            final data = doc.data() as Map<String, dynamic>;

                            return ScanHistoryCardWidget(
                              scanData: data,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.detailedReportScreen,
                                  arguments: data,
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ScanHistorySearchDelegate extends SearchDelegate<String> {
  final List<DocumentSnapshot> history;

  _ScanHistorySearchDelegate(this.history);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredHistory = history.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final riskLevel = (data['riskLevel'] ?? '').toString().toLowerCase();
      final uploadDate = (data['uploadDate'] as Timestamp?)?.toDate();
      final dateString = uploadDate?.toString().toLowerCase() ?? '';

      return riskLevel.contains(query.toLowerCase()) ||
          dateString.contains(query.toLowerCase());
    }).toList();

    if (filteredHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.secondaryLight.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "$query"',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredHistory.length,
      itemBuilder: (context, index) {
        final doc = filteredHistory[index];
        final data = doc.data() as Map<String, dynamic>;

        return ScanHistoryCardWidget(
          scanData: data,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.detailedReportScreen,
              arguments: data,
            );
          },
        );
      },
    );
  }
}
