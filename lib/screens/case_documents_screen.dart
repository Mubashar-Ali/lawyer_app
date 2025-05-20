import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import '../providers/case_provider.dart';
import '../models/case_model.dart';
import '../models/document_model.dart';
import '../widgets/document_item.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';
import '../widgets/offline_banner.dart';
import 'document_upload_screen.dart';
import 'document_view_screen.dart';

class CaseDocumentsScreen extends StatefulWidget {
  final CaseModel caseData;

  const CaseDocumentsScreen({
    super.key,
    required this.caseData,
  });

  @override
  _CaseDocumentsScreenState createState() => _CaseDocumentsScreenState();
}

class _CaseDocumentsScreenState extends State<CaseDocumentsScreen> {
  bool _isLoading = false;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<DocumentProvider>(context, listen: false).fetchDocuments();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading documents: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _confirmDelete(BuildContext context, DocumentModel document) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this document? This action cannot be undone.'),
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
                final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
                final caseProvider = Provider.of<CaseProvider>(context, listen: false);
                
                // Delete the document
                await documentProvider.deleteDocument(document.id, document.url);
                
                // Remove document reference from case
                await caseProvider.removeDocumentFromCase(widget.caseData.id, document.id);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Document deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting document: ${error.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'DELETE',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer<DocumentProvider>(
          builder: (context, documentProvider, child) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 16, left: 24, right: 24),
                    child: Text(
                      'Sort Documents',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ),
                  _buildSortOption(
                    title: 'Date (Newest first)',
                    icon: Icons.arrow_downward,
                    isSelected: documentProvider.currentSortOption == DocumentSortOption.dateNewest,
                    onTap: () {
                      documentProvider.setSortOption(DocumentSortOption.dateNewest);
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    title: 'Date (Oldest first)',
                    icon: Icons.arrow_upward,
                    isSelected: documentProvider.currentSortOption == DocumentSortOption.dateOldest,
                    onTap: () {
                      documentProvider.setSortOption(DocumentSortOption.dateOldest);
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    title: 'Name (A-Z)',
                    icon: Icons.sort_by_alpha,
                    isSelected: documentProvider.currentSortOption == DocumentSortOption.nameAZ,
                    onTap: () {
                      documentProvider.setSortOption(DocumentSortOption.nameAZ);
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    title: 'Name (Z-A)',
                    icon: Icons.sort_by_alpha,
                    isSelected: documentProvider.currentSortOption == DocumentSortOption.nameZA,
                    onTap: () {
                      documentProvider.setSortOption(DocumentSortOption.nameZA);
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    title: 'Size (Smallest first)',
                    icon: Icons.data_usage,
                    isSelected: documentProvider.currentSortOption == DocumentSortOption.sizeSmallest,
                    onTap: () {
                      documentProvider.setSortOption(DocumentSortOption.sizeSmallest);
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    title: 'Size (Largest first)',
                    icon: Icons.data_usage,
                    isSelected: documentProvider.currentSortOption == DocumentSortOption.sizeLargest,
                    onTap: () {
                      documentProvider.setSortOption(DocumentSortOption.sizeLargest);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFF1A237E) : Colors.grey[600],
              size: 20,
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Color(0xFF1A237E) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Spacer(),
            if (isSelected)
              Icon(
                Icons.check,
                color: Color(0xFF1A237E),
              ),
          ],
        ),
      ),
    );
  }

  List<DocumentModel> _filterDocuments(List<DocumentModel> documents) {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      return documents;
    }
    
    final query = _searchQuery!.toLowerCase();
    return documents.where((doc) {
      return doc.name.toLowerCase().contains(query) ||
             doc.type.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Case Documents'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DocumentSearchDelegate(
                  caseId: widget.caseData.id,
                  onResultSelected: (document) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentViewScreen(document: document),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Consumer<DocumentProvider>(
        builder: (context, documentProvider, child) {
          if (documentProvider.isOffline) {
            return Column(
              children: [
                OfflineBanner(),
                Expanded(
                  child: _buildDocumentList(documentProvider),
                ),
              ],
            );
          }
          
          if (_isLoading) {
            return Center(child: LoadingIndicator());
          }
          
          if (documentProvider.error != null) {
            return ErrorView(
              error: documentProvider.error!,
              onRetry: _loadDocuments,
            );
          }
          
          return _buildDocumentList(documentProvider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1A237E),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentUploadScreen(
                caseId: widget.caseData.id,
                caseName: widget.caseData.title,
                clientId: widget.caseData.clientId,
                clientName: widget.caseData.clientName,
              ),
            ),
          ).then((result) {
            if (result == true) {
              // Refresh documents if upload was successful
              _loadDocuments();
            }
          });
        },
      ),
    );
  }

  Widget _buildDocumentList(DocumentProvider documentProvider) {
    final caseDocuments = documentProvider.getDocumentsByCase(widget.caseData.id);
    final filteredDocuments = _filterDocuments(caseDocuments);
    
    if (filteredDocuments.isEmpty) {
      return EmptyState(
        icon: Icons.folder_open,
        title: _searchQuery != null && _searchQuery!.isNotEmpty
            ? 'No documents match your search'
            : 'No documents found for this case',
        message: _searchQuery != null && _searchQuery!.isNotEmpty
            ? 'Try a different search term or clear the search'
            : 'Add your first document by tapping the + button',
        buttonText: _searchQuery != null && _searchQuery!.isNotEmpty ? 'Clear Search' : null,
        onButtonPressed: _searchQuery != null && _searchQuery!.isNotEmpty
            ? () {
                setState(() {
                  _searchQuery = null;
                });
              }
            : null,
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: filteredDocuments.length,
        itemBuilder: (context, index) {
          final document = filteredDocuments[index];
          return Dismissible(
            key: Key(document.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              color: Colors.red,
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            confirmDismiss: (direction) async {
              _confirmDelete(context, document);
              return false;
            },
            child: DocumentItem(
              document: document,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentViewScreen(document: document),
                  ),
                );
              },
              // onDelete: () => _confirmDelete(context, document),
            ),
          );
        },
      ),
    );
  }
}

class DocumentSearchDelegate extends SearchDelegate<DocumentModel?> {
  final String caseId;
  final Function(DocumentModel) onResultSelected;

  DocumentSearchDelegate({
    required this.caseId,
    required this.onResultSelected,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final documentProvider = Provider.of<DocumentProvider>(context);
    final caseDocuments = documentProvider.getDocumentsByCase(caseId);
    
    if (query.isEmpty) {
      return Center(
        child: Text('Enter a search term'),
      );
    }
    
    final results = caseDocuments.where((doc) {
      return doc.name.toLowerCase().contains(query.toLowerCase()) ||
             doc.type.toLowerCase().contains(query.toLowerCase());
    }).toList();
    
    if (results.isEmpty) {
      return Center(
        child: Text('No documents found'),
      );
    }
    
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final document = results[index];
        return ListTile(
          // leading: Icon(document.getIconData()),
          title: Text(document.name),
          subtitle: Text('${document.type} • ${document.size}'),
          onTap: () {
            onResultSelected(document);
            close(context, document);
          },
        );
      },
    );
  }
}
