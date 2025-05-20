import 'package:flutter/material.dart';
import 'package:lawyer_app/widgets/client_list_item.dart';
import 'package:provider/provider.dart';
import '../providers/client_provider.dart';
import '../models/client_model.dart';
import '../widgets/offline_banner.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';
import 'add_client_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Fetch clients when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(context, listen: false).fetchClients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClientModel> _filterClients(List<ClientModel> clients) {
    // Filter by search query if present
    if (_searchQuery.isNotEmpty) {
      return clients.where((client) {
        return client.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            client.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            client.phone.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return clients;
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

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer<ClientProvider>(
          builder: (context, clientProvider, child) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 16, left: 24, right: 24),
                    child: Text(
                      'Sort Clients',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ),
                  _buildSortOption(
                    title: 'Name (A-Z)',
                    icon: Icons.sort_by_alpha,
                    isSelected:
                        clientProvider.currentSortOption ==
                        ClientSortOption.nameAZ,
                    onTap: () {
                      clientProvider.setSortOption(ClientSortOption.nameAZ);
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    title: 'Name (Z-A)',
                    icon: Icons.sort_by_alpha,
                    isSelected:
                        clientProvider.currentSortOption ==
                        ClientSortOption.nameZA,
                    onTap: () {
                      clientProvider.setSortOption(ClientSortOption.nameZA);
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    title: 'Date Added (Newest first)',
                    icon: Icons.arrow_downward,
                    isSelected:
                        clientProvider.currentSortOption ==
                        ClientSortOption.dateNewest,
                    onTap: () {
                      clientProvider.setSortOption(ClientSortOption.dateNewest);
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    title: 'Date Added (Oldest first)',
                    icon: Icons.arrow_upward,
                    isSelected:
                        clientProvider.currentSortOption ==
                        ClientSortOption.dateOldest,
                    onTap: () {
                      clientProvider.setSortOption(ClientSortOption.dateOldest);
                      Navigator.pop(context);
                    },
                  ),
                  _buildSortOption(
                    title: 'Most Cases',
                    icon: Icons.folder,
                    isSelected:
                        clientProvider.currentSortOption ==
                        ClientSortOption.mostCases,
                    onTap: () {
                      clientProvider.setSortOption(ClientSortOption.mostCases);
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
                    hintText: 'Search clients...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.white),
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                )
                : Text('Clients'),
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
            tooltip: 'Sort clients',
          ),
        ],
      ),
      body: Consumer<ClientProvider>(
        builder: (context, clientProvider, child) {
          if (clientProvider.isOffline) {
            return Column(
              children: [
                OfflineBanner(),
                Expanded(child: _buildClientList(clientProvider)),
              ],
            );
          }

          if (clientProvider.isLoading) {
            return Center(child: LoadingIndicator());
          }

          if (clientProvider.error != null) {
            return ErrorView(
              error: clientProvider.error!,
              onRetry: () => clientProvider.fetchClients(),
            );
          }

          return _buildClientList(clientProvider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1A237E),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddClientScreen()),
          );
        },
      ),
    );
  }

  Widget _buildClientList(ClientProvider clientProvider) {
    final filteredClients = _filterClients(clientProvider.clients);

    if (filteredClients.isEmpty) {
      return EmptyState(
        icon: Icons.people,
        title:
            _searchQuery.isNotEmpty
                ? 'No clients match your search'
                : 'No clients found',
        message:
            _searchQuery.isNotEmpty
                ? 'Try a different search term or clear the search'
                : 'Add your first client by tapping the + button',
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
      onRefresh: () => clientProvider.fetchClients(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: filteredClients.length,
        itemBuilder: (context, index) {
          final client = filteredClients[index];
          return ClientListItem(
            client: client,
            onTap: () {
              Navigator.of(
                context,
              ).pushNamed('/client-details', arguments: client);
            },
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddClientScreen(clientToEdit: client),
                ),
              );
            },
            onDelete: () {
              _confirmDelete(context, client);
            },
          );
        },
      ),
    );
  }
}
