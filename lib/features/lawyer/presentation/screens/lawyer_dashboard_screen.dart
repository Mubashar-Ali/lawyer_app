import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/case_provider.dart';
import '../../../../core/providers/appointment_provider.dart';
import '../../../../core/providers/task_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/models/appointment.dart';
import '../../../../core/models/task.dart';

import '../widgets/notification_badge.dart';
import '../widgets/stats_card.dart';
import '../widgets/appointment_card.dart';
import '../widgets/task_card.dart';

class LawyerDashboardScreen extends StatefulWidget {
  const LawyerDashboardScreen({super.key});

  @override
  State<LawyerDashboardScreen> createState() => _LawyerDashboardScreenState();
}

class _LawyerDashboardScreenState extends State<LawyerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    final activeCases = caseProvider.activeCases;
    final pendingTasks = taskProvider.pendingTasks;
    final todayAppointments = appointmentProvider.todayAppointments;
    final clients = caseProvider.cases.map((c) => c.clientId).toSet().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to search screen
            },
          ),
          NotificationBadge(
            count: notificationProvider.notificationCount,
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Navigate to notifications screen
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: caseProvider.isLoading || appointmentProvider.isLoading || taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  caseProvider.loadCases(),
                  appointmentProvider.loadAppointments(),
                  taskProvider.loadTasks(),
                  notificationProvider.loadNotifications(),
                ]);
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(),
                    const SizedBox(height: 24),
                    _buildStatsGrid(
                      activeCases.length,
                      pendingTasks.length,
                      todayAppointments.length,
                      clients,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      'Upcoming Appointments',
                      'View All',
                      () => context.go(AppConstants.lawyerCalendarRoute),
                    ),
                    const SizedBox(height: 16),
                    _buildAppointmentsList(todayAppointments),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      'Tasks Due Soon',
                      'View All',
                      () => context.go(AppConstants.lawyerTasksRoute),
                    ),
                    const SizedBox(height: 16),
                    _buildTasksList(pendingTasks),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader() {
    final now = DateTime.now();
    String greeting;
    
    if (now.hour < 12) {
      greeting = 'Good Morning';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, James',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here\'s what\'s happening today',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(int activeCases, int pendingTasks, int todayAppointments, int totalClients) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatsCard(
          title: 'Active Cases',
          value: activeCases.toString(),
          icon: Icons.gavel,
          color: AppTheme.primaryColor,
          onTap: () => context.go(AppConstants.lawyerCasesRoute),
        ),
        StatsCard(
          title: 'Pending Tasks',
          value: pendingTasks.toString(),
          icon: Icons.check_circle_outline,
          color: Colors.orange,
          onTap: () => context.go(AppConstants.lawyerTasksRoute),
        ),
        StatsCard(
          title: 'Today\'s Appointments',
          value: todayAppointments.toString(),
          icon: Icons.calendar_today,
          color: Colors.green,
          onTap: () => context.go(AppConstants.lawyerCalendarRoute),
        ),
        StatsCard(
          title: 'Total Clients',
          value: totalClients.toString(),
          icon: Icons.people_outline,
          color: Colors.purple,
          onTap: () => context.go(AppConstants.lawyerClientsRoute),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String actionText, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return _buildEmptyState(
        'No appointments for today',
        'Schedule a new appointment',
        Icons.event_available,
        () {},
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length > 3 ? 3 : appointments.length,
      itemBuilder: (context, index) {
        return AppointmentCard(
          appointment: appointments[index],
          onTap: () {},
        );
      },
    );
  }

  Widget _buildTasksList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return _buildEmptyState(
        'No pending tasks',
        'Create a new task',
        Icons.task_alt,
        () {},
      );
    }
    
    // Sort tasks by due date and priority
    final sortedTasks = List<Task>.from(tasks);
    sortedTasks.sort((a, b) {
      // First sort by due date
      final dateComparison = a.dueDate.compareTo(b.dueDate);
      if (dateComparison != 0) return dateComparison;
      
      // Then by priority (high -> medium -> low)
      final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
      return priorityOrder[a.priority.toLowerCase()]!.compareTo(
        priorityOrder[b.priority.toLowerCase()]!
      );
    });
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedTasks.length > 4 ? 4 : sortedTasks.length,
      itemBuilder: (context, index) {
        return TaskCard(
          task: sortedTasks[index],
          onStatusChanged: (value) {
            // Update task status
            Provider.of<TaskProvider>(context, listen: false)
                .toggleTaskStatus(sortedTasks[index].id);
          },
          onTap: () {},
        );
      },
    );
  }

  Widget _buildEmptyState(
    String message,
    String buttonText,
    IconData icon,
    VoidCallback onAction,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
