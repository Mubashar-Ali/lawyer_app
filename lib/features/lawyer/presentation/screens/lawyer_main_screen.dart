import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/case_provider.dart';
import '../../../../core/providers/client_provider.dart';
import '../../../../core/providers/appointment_provider.dart';
import '../../../../core/providers/task_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/providers/document_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_constants.dart';

import '../widgets/notification_badge.dart';

class LawyerMainScreen extends StatefulWidget {
  final Widget child;

  const LawyerMainScreen({super.key, required this.child});

  @override
  State<LawyerMainScreen> createState() => _LawyerMainScreenState();
}

class _LawyerMainScreenState extends State<LawyerMainScreen> {
  int _currentIndex = 0;
  final List<String> _routes = [
    AppConstants.lawyerDashboardRoute,
    AppConstants.lawyerCasesRoute,
    AppConstants.lawyerClientsRoute,
    AppConstants.lawyerCalendarRoute,
    AppConstants.lawyerProfileRoute,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load all data in parallel
    await Future.wait([
      Provider.of<CaseProvider>(context, listen: false).loadCases(),
      Provider.of<ClientProvider>(context, listen: false).loadClients(),
      Provider.of<AppointmentProvider>(
        context,
        listen: false,
      ).loadAppointments(),
      Provider.of<TaskProvider>(context, listen: false).loadTasks(),
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).loadNotifications(),
      Provider.of<DocumentProvider>(context, listen: false).loadDocuments(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Update current index based on current route
    final String location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i])) {
        _currentIndex = i;
        break;
      }
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          context.go(_routes[index]);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const NavigationDestination(
            icon: Icon(Icons.gavel_outlined),
            selectedIcon: Icon(Icons.gavel),
            label: 'Cases',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Clients',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                return NotificationBadge(
                  count: provider.notificationCount,
                  child: const Icon(Icons.person_outline),
                );
              },
            ),
            selectedIcon: Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                return NotificationBadge(
                  count: provider.notificationCount,
                  child: const Icon(Icons.person),
                );
              },
            ),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    // Show FAB based on current route
    if (_currentIndex == 0) {
      return FloatingActionButton(
        onPressed: () {
          _showAddMenu(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      );
    } else if (_currentIndex == 1) {
      return FloatingActionButton(
        onPressed: () {
          context.push('${AppConstants.lawyerCasesRoute}/add');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add,  color: Colors.white),
      );
    } else if (_currentIndex == 2) {
      return FloatingActionButton(
        onPressed: () {
          context.push('${AppConstants.lawyerClientsRoute}/add');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      );
    } else if (_currentIndex == 3) {
      return FloatingActionButton(
        onPressed: () {
          context.push('${AppConstants.lawyerCalendarRoute}/add');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    return null;
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add New',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildAddMenuItem(
                context,
                icon: Icons.gavel,
                title: 'New Case',
                onTap: () {
                  Navigator.pop(context);
                  context.push('${AppConstants.lawyerDashboardRoute}/add-case');
                },
              ),
              _buildAddMenuItem(
                context,
                icon: Icons.person_add,
                title: 'New Client',
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    '${AppConstants.lawyerDashboardRoute}/add-client',
                  );
                },
              ),
              _buildAddMenuItem(
                context,
                icon: Icons.event,
                title: 'New Appointment',
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    '${AppConstants.lawyerDashboardRoute}/add-appointment',
                  );
                },
              ),
              _buildAddMenuItem(
                context,
                icon: Icons.task,
                title: 'New Task',
                onTap: () {
                  Navigator.pop(context);
                  context.push('${AppConstants.lawyerDashboardRoute}/add-task');
                },
              ),
              _buildAddMenuItem(
                context,
                icon: Icons.upload_file,
                title: 'Upload Document',
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    '${AppConstants.lawyerDashboardRoute}/add-document',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
