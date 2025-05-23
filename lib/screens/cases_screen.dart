import 'package:flutter/material.dart';
import 'package:lawyer_app/widgets/case_list_item.dart';
import 'package:provider/provider.dart';
import '../providers/case_provider.dart';
import '../models/case_model.dart';
import '../widgets/offline_banner.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';
import 'add_case_screen.dart';

class CasesScreen extends StatefulWidget {
  const CasesScreen({super.key});

  @override
  _CasesScreenState createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Fetch cases when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CaseProvider>(context, listen: false).fetchCases();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<CaseModel> _filterCases(List<CaseModel> cases, String status) {
    List<CaseModel> filteredCases = cases;

    // Filter by status if not "All"
    if (status != 'All') {
      filteredCases =
          cases.where((caseItem) => caseItem.status == status).toList();
    }

    // Filter by search query if present
    if (_searchQuery.isNotEmpty) {
      filteredCases =
          filteredCases.where((caseItem) {
            return caseItem.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                caseItem.caseNumber.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                caseItem.clientName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                caseItem.court.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                caseItem.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();
    }

    return filteredCases;
  }

  void _confirmDelete(BuildContext context, CaseModel caseItem) {
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
                    ).deleteCase(caseItem.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Case deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
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

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer<CaseProvider>(
          builder: (context, caseProvider, child) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 16, left: 24, right: 24),
                    child: Text(
                      'Sort Cases',
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
                    isSelected:
                        caseProvider.currentSortOption ==
                        CaseSortOption.dateNewest,
                    onTap: () {
                      caseProvider.setSortOption(CaseSortOption.dateNewest);
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    title: 'Date (Oldest first)',
                    icon: Icons.arrow_upward,
                    isSelected:
                        caseProvider.currentSortOption ==
                        CaseSortOption.dateOldest,
                    onTap: () {
                      caseProvider.setSortOption(CaseSortOption.dateOldest);
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    title: 'Title (A-Z)',
                    icon: Icons.sort_by_alpha,
                    isSelected:
                        caseProvider.currentSortOption ==
                        CaseSortOption.titleAZ,
                    onTap: () {
                      caseProvider.setSortOption(CaseSortOption.titleAZ);
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    title: 'Title (Z-A)',
                    icon: Icons.sort_by_alpha,
                    isSelected:
                        caseProvider.currentSortOption ==
                        CaseSortOption.titleZA,
                    onTap: () {
                      caseProvider.setSortOption(CaseSortOption.titleZA);
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    title: 'Status (Active first)',
                    icon: Icons.check_circle_outline,
                    isSelected:
                        caseProvider.currentSortOption ==
                        CaseSortOption.statusActive,
                    onTap: () {
                      caseProvider.setSortOption(CaseSortOption.statusActive);
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    title: 'Status (Closed first)',
                    icon: Icons.cancel_outlined,
                    isSelected:
                        caseProvider.currentSortOption ==
                        CaseSortOption.statusClosed,
                    onTap: () {
                      caseProvider.setSortOption(CaseSortOption.statusClosed);
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
            if (isSelected) Icon(Icons.check, color: Color(0xFF1A237E)),
          ],
        ),
      ),
    );
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
                    hintText: 'Search cases...',
                    hintStyle: TextStyle(color: Colors.white70),
                    // border: InputBorder.none,
                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(8),
                    //   borderSide: BorderSide(color: Colors.white70),
                    // ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                )
                : Text('Cases'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Sort cases',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Pending'),
            Tab(text: 'Closed'),
          ],
        ),
      ),
      body: Consumer<CaseProvider>(
        builder: (context, caseProvider, child) {
          if (caseProvider.isOffline) {
            return Column(
              children: [
                OfflineBanner(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCaseList(caseProvider.cases, 'All'),
                      _buildCaseList(caseProvider.cases, 'Active'),
                      _buildCaseList(caseProvider.cases, 'Pending'),
                      _buildCaseList(caseProvider.cases, 'Closed'),
                    ],
                  ),
                ),
              ],
            );
          }

          if (caseProvider.isLoading) {
            return Center(child: LoadingIndicator());
          }

          if (caseProvider.error != null) {
            return ErrorView(
              error: caseProvider.error!,
              onRetry: () => caseProvider.fetchCases(),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCaseList(caseProvider.cases, 'All'),
              _buildCaseList(caseProvider.cases, 'Active'),
              _buildCaseList(caseProvider.cases, 'Pending'),
              _buildCaseList(caseProvider.cases, 'Closed'),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1A237E),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCaseScreen()),
          );
        },
      ),
    );
  }

  Widget _buildCaseList(List<CaseModel> cases, String status) {
    final filteredCases = _filterCases(cases, status);

    if (filteredCases.isEmpty) {
      return EmptyState(
        icon: Icons.gavel,
        title:
            _searchQuery.isNotEmpty
                ? 'No cases match your search'
                : 'No $status cases found',
        message:
            _searchQuery.isNotEmpty
                ? 'Try a different search term or clear the search'
                : status == 'All'
                ? 'Add your first case by tapping the + button'
                : 'Cases with $status status will appear here',
        buttonText: _searchQuery.isNotEmpty ? 'Clear Search' : null,
        onButtonPressed:
            _searchQuery.isNotEmpty
                ? () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _isSearching = false;
                  });
                }
                : null,
      );
    }

    return RefreshIndicator(
      onRefresh:
          () => Provider.of<CaseProvider>(context, listen: false).fetchCases(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: filteredCases.length,
        itemBuilder: (context, index) {
          final caseItem = filteredCases[index];
          return CaseListItem(
            caseItem: caseItem,
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed('/case-details', arguments: caseItem);
            },
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCaseScreen(caseToEdit: caseItem),
                ),
              );
            },
            onDelete: () {
              _confirmDelete(context, caseItem);
            },
          );
        },
      ),
    );
  }
}
