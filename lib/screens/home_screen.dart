import 'package:flutter/material.dart';
import 'package:lawyer_app/screens/cases_screen.dart';
import 'package:lawyer_app/screens/client_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/case_provider.dart';
import '../providers/client_provider.dart';
import '../providers/event_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/recent_case_item.dart';
import '../widgets/upcoming_event_item.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'add_client_screen.dart';
import 'add_event_screen.dart';
import 'calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check connectivity first
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnectivity = connectivityResult != ConnectivityResult.none;

      if (hasConnectivity) {
        await Future.wait([
          Provider.of<CaseProvider>(context, listen: false).fetchCases(),
          Provider.of<ClientProvider>(context, listen: false).fetchClients(),
          Provider.of<EventProvider>(context, listen: false).fetchEvents(),
        ]);
      } else {
        // If offline, still try to load cached data
        Provider.of<CaseProvider>(context, listen: false).fetchCases();
        Provider.of<ClientProvider>(context, listen: false).fetchClients();
        Provider.of<EventProvider>(context, listen: false).fetchEvents();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You are offline. Using cached data.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CasesScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClientsScreen()),
        );
        break;
      case 3:
        Navigator.of(context).pushNamed('/calendar');
        break;
      case 4:
        Navigator.of(context).pushNamed('/documents');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final caseProvider = Provider.of<CaseProvider>(context);
    final clientProvider = Provider.of<ClientProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Legal Pro'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              // Implement notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${authProvider.currentUser?.displayName ?? 'Lawyer'}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: DashboardCard(
                              title: 'Active Cases',
                              value: caseProvider.activeCases.length.toString(),
                              icon: Icons.gavel,
                              color: Color(0xFF1A237E),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CasesScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: DashboardCard(
                              title: 'Clients',
                              value: clientProvider.clients.length.toString(),
                              icon: Icons.people,
                              color: Color(0xFF303F9F),
                              onTap: () {
                                Navigator.of(context).pushNamed('/clients');
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DashboardCard(
                              title: 'Upcoming',
                              value:
                                  eventProvider
                                      .getUpcomingEvents()
                                      .length
                                      .toString(),
                              icon: Icons.event,
                              color: Color(0xFF3949AB),
                              onTap: () {
                                Navigator.of(context).pushNamed('/calendar');
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: DashboardCard(
                              title: 'Documents',
                              value: '12',
                              icon: Icons.description,
                              color: Color(0xFF5C6BC0),
                              onTap: () {
                                Navigator.of(context).pushNamed('/documents');
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Upcoming Events',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CalendarScreen(),
                                ),
                              );
                            },
                            child: Text('View All'),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      eventProvider.getUpcomingEvents().isEmpty
                          ? Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No upcoming events',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                          : Column(
                            children:
                                eventProvider
                                    .getUpcomingEvents()
                                    .take(3)
                                    .map(
                                      (event) => UpcomingEventItem(
                                        title: event.title,
                                        client: event.clientName ?? 'No client',
                                        dateTime: event.dateTime,
                                        location: event.location,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => AddEventScreen(
                                                    event: event,
                                                  ),
                                            ),
                                          ).then((_) => _loadData());
                                        },
                                      ),
                                    )
                                    .toList(),
                          ),
                      SizedBox(height: 32),
                      Text(
                        'Recent Cases',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      caseProvider.recentCases.isEmpty
                          ? Center(
                            child: Text(
                              'No recent cases',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                caseProvider.recentCases.length > 3
                                    ? 3
                                    : caseProvider.recentCases.length,
                            itemBuilder: (context, index) {
                              final caseItem = caseProvider.recentCases[index];
                              return RecentCaseItem(
                                caseItem: caseItem,
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    '/case-details',
                                    arguments: caseItem,
                                  );
                                },
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gavel_outlined),
            activeIcon: Icon(Icons.gavel),
            label: 'Cases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Documents',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1A237E),
        child: Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder:
                (context) => Container(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Add New',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 24),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF1A237E).withOpacity(0.1),
                          child: Icon(Icons.gavel, color: Color(0xFF1A237E)),
                        ),
                        title: Text('New Case'),
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to add case screen
                        },
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF1A237E).withOpacity(0.1),
                          child: Icon(
                            Icons.person_add,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        title: Text('New Client'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddClientScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF1A237E).withOpacity(0.1),
                          child: Icon(
                            Icons.event_note,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        title: Text('New Event'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEventScreen(),
                            ),
                          ).then((_) => _loadData());
                        },
                      ),
                    ],
                  ),
                ),
          );
        },
      ),
    );
  }
}
