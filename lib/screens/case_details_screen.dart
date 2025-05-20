import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lawyer_app/screens/calendar_screen.dart';
import 'package:provider/provider.dart';
import '../models/case_model.dart';
import '../providers/case_provider.dart';
import '../providers/document_provider.dart';
import '../widgets/detail_item.dart';
import '../widgets/timeline_item.dart';
import '../widgets/document_item.dart';
import 'add_case_screen.dart';
import 'document_upload_screen.dart';
import 'document_view_screen.dart';
import 'case_documents_screen.dart';

class CaseDetailsScreen extends StatefulWidget {
  const CaseDetailsScreen({super.key});

  @override
  _CaseDetailsScreenState createState() => _CaseDetailsScreenState();
}

class _CaseDetailsScreenState extends State<CaseDetailsScreen> {
  bool _isLoadingDocuments = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoadingDocuments = true;
    });

    try {
      await Provider.of<DocumentProvider>(
        context,
        listen: false,
      ).fetchDocuments();
    } catch (error) {
      // Handle error silently
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDocuments = false;
        });
      }
    }
  }

  void _confirmDelete(BuildContext context, CaseModel caseData) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete this case? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('CANCEL'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  try {
                    await Provider.of<CaseProvider>(
                      context,
                      listen: false,
                    ).deleteCase(caseData.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Case deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop(); // Return to previous screen
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error deleting case: ${error.toString()}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('DELETE', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CaseModel caseData =
        ModalRoute.of(context)!.settings.arguments as CaseModel;

    return Scaffold(
      appBar: AppBar(
        title: Text('Case Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCaseScreen(caseToEdit: caseData),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _confirmDelete(context, caseData);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                caseData.status == 'Active'
                                    ? Colors.green.withOpacity(0.1)
                                    : caseData.status == 'Pending'
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            caseData.status,
                            style: TextStyle(
                              color:
                                  caseData.status == 'Active'
                                      ? Colors.green
                                      : caseData.status == 'Pending'
                                      ? Colors.orange
                                      : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Case #${caseData.caseNumber}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      caseData.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    DetailItem(
                      icon: Icons.person,
                      title: 'Client',
                      value: caseData.clientName,
                    ),
                    DetailItem(
                      icon: Icons.category,
                      title: 'Case Type',
                      value: caseData.caseType,
                    ),
                    DetailItem(
                      icon: Icons.gavel,
                      title: 'Court',
                      value: caseData.court,
                    ),
                    DetailItem(
                      icon: Icons.calendar_today,
                      title: 'Filing Date',
                      value: DateFormat(
                        'dd MMM yyyy',
                      ).format(caseData.filingDate),
                    ),
                    DetailItem(
                      icon: Icons.calendar_today,
                      title: 'Next Hearing',
                      value:
                          caseData.nextHearing != null
                              ? DateFormat(
                                'dd MMM yyyy',
                              ).format(caseData.nextHearing!)
                              : 'Not scheduled',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Case Description',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  caseData.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Case Timeline',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TimelineItem(
                      title: 'Case Filed',
                      date: DateFormat(
                        'dd MMM yyyy',
                      ).format(caseData.filingDate),
                      description: 'Case was filed in ${caseData.court}',
                      isFirst: true,
                    ),
                    TimelineItem(
                      title: 'Initial Hearing',
                      date: '15 Mar 2023',
                      description:
                          'Initial hearing completed. Next hearing scheduled.',
                    ),
                    TimelineItem(
                      title: 'Document Submission',
                      date: '22 Apr 2023',
                      description:
                          'All required documents submitted to the court.',
                    ),
                    TimelineItem(
                      title: 'Next Hearing',
                      date:
                          caseData.nextHearing != null
                              ? DateFormat(
                                'dd MMM yyyy',
                              ).format(caseData.nextHearing!)
                              : 'Not scheduled',
                      description: 'Upcoming hearing for case proceedings.',
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Related Documents',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                CaseDocumentsScreen(caseData: caseData),
                      ),
                    );
                  },
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 8),
            _isLoadingDocuments
                ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                )
                : Consumer<DocumentProvider>(
                  builder: (context, documentProvider, child) {
                    final caseDocuments = documentProvider.getDocumentsByCase(
                      caseData.id,
                    );

                    if (caseDocuments.isEmpty) {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No documents found for this case',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: Icon(Icons.upload_file),
                                label: Text('UPLOAD DOCUMENT'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => DocumentUploadScreen(
                                            caseId: caseData.id,
                                            caseName: caseData.title,
                                            clientId: caseData.clientId,
                                            clientName: caseData.clientName,
                                          ),
                                    ),
                                  ).then(
                                    (_) => _loadDocuments(),
                                  ); // Refresh after upload
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1A237E),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          for (
                            int i = 0;
                            i < caseDocuments.length && i < 3;
                            i++
                          ) ...[
                            DocumentItem(
                              document: caseDocuments[i],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => DocumentViewScreen(
                                          document: caseDocuments[i],
                                        ),
                                  ),
                                );
                              },
                            ),
                            if (i < caseDocuments.length - 1 && i < 2)
                              Divider(height: 1),
                          ],
                          if (caseDocuments.length > 3)
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => CaseDocumentsScreen(
                                            caseData: caseData,
                                          ),
                                    ),
                                  );
                                },
                                child: Text(
                                  '+ ${caseDocuments.length - 3} more documents',
                                  style: TextStyle(
                                    color: Color(0xFF1A237E),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.event, color: Colors.white),
                  label: Text(
                    'Add Hearing',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CalendarScreen(caseData: caseData),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF303F9F),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.upload_file, color: Colors.white),
                  label: Text(
                    'Add Document',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DocumentUploadScreen(
                              caseId: caseData.id,
                              caseName: caseData.title,
                              clientId: caseData.clientId,
                              clientName: caseData.clientName,
                            ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
