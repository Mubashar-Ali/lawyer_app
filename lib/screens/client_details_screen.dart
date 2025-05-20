import 'package:flutter/material.dart';
import 'package:lawyer_app/screens/document_view_screen.dart';
import 'package:lawyer_app/widgets/case_list_item.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/client_model.dart';
import '../providers/client_provider.dart';
import '../providers/case_provider.dart';
import '../providers/document_provider.dart';
import '../widgets/detail_item.dart';
import '../widgets/document_item.dart';
import '../widgets/loading_indicator.dart';
import 'add_client_screen.dart';
import 'document_upload_screen.dart';
import 'add_case_screen.dart';

class ClientDetailsScreen extends StatefulWidget {
  const ClientDetailsScreen({super.key});

  @override
  _ClientDetailsScreenState createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  bool _isLoadingCases = false;
  bool _isLoadingDocuments = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingCases = true;
      _isLoadingDocuments = true;
    });

    try {
      await Provider.of<CaseProvider>(context, listen: false).fetchCases();
      await Provider.of<DocumentProvider>(
        context,
        listen: false,
      ).fetchDocuments();
    } catch (error) {
      // Handle error silently
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCases = false;
          _isLoadingDocuments = false;
        });
      }
    }
  }

  void _confirmDelete(BuildContext context, ClientModel client) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete this client? This action cannot be undone.',
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
                    await Provider.of<ClientProvider>(
                      context,
                      listen: false,
                    ).deleteClient(client.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Client deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop(); // Return to previous screen
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error deleting client: ${error.toString()}',
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ClientModel client =
        ModalRoute.of(context)!.settings.arguments as ClientModel;
    final caseProvider = Provider.of<CaseProvider>(context);
    final documentProvider = Provider.of<DocumentProvider>(context);

    final clientCases = caseProvider.getCasesByClientId(client.id);
    final clientDocuments = documentProvider.getDocumentsByClient(client.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('Client Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddClientScreen(clientToEdit: client),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _confirmDelete(context, client);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
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
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xFF1A237E),
                            child: Text(
                              client.initials,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Client since ${client.clientSinceFormatted}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      DetailItem(
                        icon: Icons.email,
                        title: 'Email',
                        value: client.email,
                      ),
                      DetailItem(
                        icon: Icons.phone,
                        title: 'Phone',
                        value: client.phone,
                      ),
                      DetailItem(
                        icon: Icons.location_on,
                        title: 'Address',
                        value: client.address,
                      ),
                      DetailItem(
                        icon: Icons.folder,
                        title: 'Cases',
                        value:
                            '${client.caseCount} case${client.caseCount != 1 ? 's' : ''}',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text('Cases', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              _isLoadingCases
                  ? Center(child: LoadingIndicator())
                  : clientCases.isEmpty
                  ? Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.folder_open, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No cases found for this client',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text('ADD CASE'),
                            onPressed: () {
                              // Navigate to add case screen with pre-filled client info
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddCaseScreen(),
                                  settings: RouteSettings(
                                    arguments: {
                                      'clientId': client.id,
                                      'clientName': client.name,
                                    },
                                  ),
                                ),
                              ).then(
                                (_) => _loadData(),
                              ); // Refresh data when returning
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1A237E),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Column(
                    children: [
                      for (var caseItem in clientCases.take(3))
                        CaseListItem(
                          caseItem: caseItem,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed('/case-details', arguments: caseItem);
                          },
                          onEdit: () {
                            // Navigator.pushNamed(
                            //   context,
                            //   '/add-case',
                            //   arguments: {'caseToEdit': caseItem}
                            // );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        AddCaseScreen(caseToEdit: caseItem),
                              ),
                            ).then(
                              (_) => _loadData(),
                            ); // Refresh data when returning
                          },
                          onDelete: () {
                            // Implement delete case
                          },
                        ),
                      if (clientCases.length > 3)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: TextButton(
                            onPressed: () {
                              // Navigate to a screen showing all client cases
                            },
                            child: Text(
                              'View all ${clientCases.length} cases',
                              style: TextStyle(
                                color: Color(0xFF1A237E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              SizedBox(height: 24),
              Text('Documents', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              _isLoadingDocuments
                  ? Center(child: LoadingIndicator())
                  : clientDocuments.isEmpty
                  ? Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.description, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No documents found for this client',
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
                                        clientId: client.id,
                                        clientName: client.name,
                                        category: 'Client',
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1A237E),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Column(
                    children: [
                      for (var document in clientDocuments.take(3))
                        DocumentItem(
                          document: document,
                          onTap: () {
                            // Navigate to document view
                            // Navigator.pushNamed(
                            //   context,
                            //   '/document-view',
                            //   arguments: document,
                            // );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        DocumentViewScreen(document: document),
                              ),
                            );
                          },
                        ),
                      if (clientDocuments.length > 3)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: TextButton(
                            onPressed: () {
                              // Navigate to a screen showing all client documents
                            },
                            child: Text(
                              'View all ${clientDocuments.length} documents',
                              style: TextStyle(
                                color: Color(0xFF1A237E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.phone, color: Colors.white),
                  label: Text('Call'),
                  onPressed: () => _makePhoneCall(client.phone),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.email, color: Colors.white),
                  label: Text('Email'),
                  onPressed: () => _sendEmail(client.email),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
