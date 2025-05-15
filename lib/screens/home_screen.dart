import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/appointment_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back, James',
              style: TextStyle(
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
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatsCard(
                  title: 'Active Cases',
                  value: '12',
                  icon: Icons.gavel,
                  color: AppTheme.primaryColor,
                  onTap: () {},
                ),
                StatsCard(
                  title: 'Pending Tasks',
                  value: '8',
                  icon: Icons.check_circle_outline,
                  color: Colors.orange,
                  onTap: () {},
                ),
                StatsCard(
                  title: 'Today\'s Appointments',
                  value: '3',
                  icon: Icons.calendar_today,
                  color: Colors.green,
                  onTap: () {},
                ),
                StatsCard(
                  title: 'Total Clients',
                  value: '24',
                  icon: Icons.people_outline,
                  color: Colors.purple,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Upcoming Appointments', 'View All', () {}),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return AppointmentCard(
                  appointment: dummyAppointments[index],
                  onTap: () {},
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Tasks Due Soon', 'View All', () {}),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                return TaskCard(
                  task: dummyTasks[index],
                  onStatusChanged: (value) {
                    // In a real app, you would update the task status here
                  },
                  onTap: () {},
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
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
}
