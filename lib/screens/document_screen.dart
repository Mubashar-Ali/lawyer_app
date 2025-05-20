import 'package:flutter/material.dart';
import 'package:lawyer_app/models/document_model.dart';
import 'package:lawyer_app/providers/document_provider.dart';
import 'package:lawyer_app/screens/document_view_screen.dart';
import 'package:lawyer_app/screens/document_upload_screen.dart';
import 'package:lawyer_app/widgets/document_item.dart';
import 'package:lawyer_app/widgets/loading_indicator.dart';
import 'package:lawyer_app/widgets/empty_state.dart';
import 'package:provider/provider.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  _DocumentScreenState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isLoading = false;

  // Filter options
  String? _selectedDateRange;

  List<DocumentModel> _documents = [];
  List<DocumentModel> _filteredDocuments = [];
  final Set<String> _selectedTypes = {};
  String? _currentFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadDocuments();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            break;
          case 1:
            break;
          case 2:
            break;
          // case 3:
          //   _selectedCategory = 'Templates';
          //   break;
        }
      });
    }
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<DocumentModel> loadedDocuments =
          await Provider.of<DocumentProvider>(
            context,
            listen: false,
          ).fetchDocuments();
      setState(() {
        _documents = loadedDocuments;
        _filterDocuments();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading documents: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search documents...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.white),
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _filterDocuments();
                  },
                )
                : Text('Documents'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                  _filterDocuments();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadDocuments),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildTabs(),
          ),
        ),
      ),
      body:
          _isLoading ? Center(child: LoadingIndicator()) : _buildDocumentList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1A237E),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DocumentUploadScreen()),
          ).then((_) => _loadDocuments());
        },
      ),
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey[500],
      tabs: [
        Tab(text: 'All'),
        Tab(text: 'Cases'),
        Tab(text: 'Clients'),
        Tab(text: 'General'),
      ],
      onTap: (index) {
        setState(() {
          _currentFilter = switch (index) {
            0 => null,
            1 => 'case',
            2 => 'client',
            3 => 'general',
            _ => null,
          };
          _filterDocuments();
        });
      },
    );
  }

  Widget _buildDocumentList() {
    if (_filteredDocuments.isEmpty) {
      return EmptyState(
        icon: Icons.folder_open,
        message: 'No documents found',
        title: 'Try adding some',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _filteredDocuments.length,
        itemBuilder: (context, index) {
          final doc = _filteredDocuments[index];
          return DocumentItem(
            document: doc,
            onTap: () => _navigateToDocumentView(doc),
            onDelete: () {
              _deleteDocument(doc);
              setState(() {});
            },
          );
        },
      ),
    );
  }

  void _filterDocuments() {
    if (_documents.isEmpty) {
      _filteredDocuments = [];
      return;
    }

    _filteredDocuments =
        _documents.where((doc) {
          // Apply search filter
          final matchesSearch =
              _searchQuery.isEmpty ||
              doc.name.toLowerCase().contains(_searchQuery.toLowerCase());

          // Apply category filter
          final matchesCategory =
              _currentFilter == null || doc.category == _currentFilter;

          // Apply type filter
          final matchesType =
              _selectedTypes.isEmpty ||
              _selectedTypes.contains(doc.type.toLowerCase());

          // Apply date filter
          bool matchesDate = true;
          if (_selectedDateRange != null) {
            final now = DateTime.now();
            final uploadDate = doc.uploadDate;

            switch (_selectedDateRange) {
              case 'last7days':
                matchesDate = now.difference(uploadDate).inDays <= 7;
                break;
              case 'last30days':
                matchesDate = now.difference(uploadDate).inDays <= 30;
                break;
              case 'last90days':
                matchesDate = now.difference(uploadDate).inDays <= 90;
                break;
            }
          }

          return matchesSearch && matchesCategory && matchesType && matchesDate;
        }).toList();

    // Sort by upload date (newest first)
    _filteredDocuments.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
  }

  void _navigateToDocumentView(DocumentModel document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewScreen(document: document),
      ),
    ).then((_) => _loadDocuments());
  }

  Future<void> _deleteDocument(DocumentModel document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Document'),
            content: Text(
              'Are you sure you want to delete "${document.name}"?',
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<DocumentProvider>(
          context,
          listen: false,
        ).deleteDocument(document.id, document.url);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting document: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text('Filter Documents'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document Type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children:
                              ['PDF', 'DOCX', 'XLSX', 'JPG', 'PNG', 'ZIP'].map((
                                type,
                              ) {
                                return FilterChip(
                                  label: Text(type),
                                  selected: _selectedTypes.contains(
                                    type.toLowerCase(),
                                  ),
                                  onSelected: (selected) {
                                    setDialogState(() {
                                      if (selected) {
                                        _selectedTypes.add(type.toLowerCase());
                                      } else {
                                        _selectedTypes.remove(
                                          type.toLowerCase(),
                                        );
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Date Range',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children:
                              [
                                'Last 7 days',
                                'Last 30 days',
                                'Last 90 days',
                              ].map((range) {
                                String rangeValue = range
                                    .toLowerCase()
                                    .replaceAll(' ', '');
                                return FilterChip(
                                  label: Text(range),
                                  selected: _selectedDateRange == rangeValue,
                                  onSelected: (selected) {
                                    setDialogState(() {
                                      _selectedDateRange =
                                          selected ? rangeValue : null;
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text('Clear Filters'),
                      onPressed: () {
                        setDialogState(() {
                          _selectedTypes.clear();
                          _selectedDateRange = null;
                        });
                      },
                    ),
                    TextButton(
                      child: Text('Apply'),
                      onPressed: () {
                        setState(() {
                          _filterDocuments();
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
          ),
    );
  }
}
