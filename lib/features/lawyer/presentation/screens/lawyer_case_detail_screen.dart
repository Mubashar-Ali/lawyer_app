import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/case_provider.dart';
import '../../../../core/models/case.dart';
import '../../../../core/theme/app_theme.dart';

class LawyerCaseDetailScreen extends StatelessWidget {
  final String caseId;
  
  const LawyerCaseDetailScreen({
    super.key,
    required this.caseId,
  });

  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);
    final caseItem = caseProvider.getCaseById(caseId);
    
    if (caseItem == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Case Details'),
        ),
        body: const Center(
          child: Text('Case not found'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit case screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(context, caseItem);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCaseHeader(context, caseItem),
            const SizedBox(height: 24),
            _buildCaseDetails(context, caseItem),
            const SizedBox(height: 24),
            _buildCaseDescription(context, caseItem),
            const SizedBox(height: 24),
            _buildCaseTimeline(context, caseItem),
            const SizedBox(height: 24),
            _buildRelatedItems(context, caseItem),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                Icons.event_outlined,
                'Add Appointment',
                () {
                  // Navigate to add appointment screen
                },
              ),
              _buildActionButton(
                context,
                Icons.task_outlined,
                'Add Task',
                () {
                  // Navigate to add task screen
                },
              ),
              _buildActionButton(
                context,
                Icons.upload_file_outlined,
                'Add Document',
                () {
                  // Navigate to add document screen
                },
              ),
              _buildActionButton(
                context,
                Icons.note_outlined,
                'Add Note',
                () {
                  // Show add note dialog
                  _showAddNoteDialog(context, caseItem);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaseHeader(BuildContext context, Case caseItem) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        caseItem.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Case #: ${caseItem.caseNumber}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(caseItem.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Client: ${caseItem.clientName}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Type: ${caseItem.caseType}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (caseItem.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: caseItem.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCaseDetails(BuildContext context, Case caseItem) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Case Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Court', caseItem.court),
            _buildDetailRow('Judge', caseItem.judge ?? 'Not assigned'),
            _buildDetailRow('Filed Date', dateFormat.format(caseItem.filingDate)),
            _buildDetailRow('Next Hearing', dateFormat.format(caseItem.nextHearing)),
            // _buildDetailRow('Statute of Limitations', 
            //     caseItem.statuteOfLimitations != null 
            //         ? dateFormat.format(caseItem.statuteOfLimitations!)
            //         : 'Not applicable'),
            // _buildDetailRow('Opposing Counsel', caseItem.opposingCounsel ?? 'Not specified'),
            // _buildDetailRow('Opposing Party', caseItem.opposingParty ?? 'Not specified'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseDescription(BuildContext context, Case caseItem) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Case Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              caseItem.description,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseTimeline(BuildContext context, Case caseItem) {
    // This would be populated with actual timeline events from the case
    // For now, we'll use dummy data
    final events = [
      {
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'title': 'Case Filed',
        'description': 'Initial case filing with the court',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 20)),
        'title': 'Discovery Phase Started',
        'description': 'Began collecting evidence and depositions',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 20)),
        'title': 'Discovery Phase Started',
        'description': 'Began collecting evidence and depositions',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 10)),
        'title': 'Motion Filed',
        'description': 'Filed motion to dismiss counterclaims',
      },
      {
        'date': DateTime.now().add(const Duration(days: 15)),
        'title': 'Upcoming Hearing',
        'description': 'Scheduled court appearance for preliminary motions',
      },
    ];
    
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Case Timeline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // View all timeline events
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final date = event['date'] as DateTime;
                final title = event['title'] as String;
                final description = event['description'] as String;
                
                final isLast = index == events.length - 1;
                final isFuture = date.isAfter(DateTime.now());
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFuture ? Colors.grey : AppTheme.primaryColor,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 70,
                            color: Colors.grey[300],
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateFormat.format(date),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isFuture ? Colors.grey[600] : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedItems(BuildContext context, Case caseItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Related Items',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRelatedItemCard(
                context,
                Icons.event_outlined,
                'Appointments',
                '3 Upcoming',
                Colors.blue,
                () {
                  // Navigate to case appointments
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRelatedItemCard(
                context,
                Icons.task_outlined,
                'Tasks',
                '5 Pending',
                Colors.orange,
                () {
                  // Navigate to case tasks
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRelatedItemCard(
                context,
                Icons.folder_outlined,
                'Documents',
                '12 Files',
                Colors.green,
                () {
                  // Navigate to case documents
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRelatedItemCard(
                context,
                Icons.note_outlined,
                'Notes',
                '8 Notes',
                Colors.purple,
                () {
                  // Navigate to case notes
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRelatedItemCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, Case caseItem) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Case'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to edit case screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.content_copy_outlined),
                title: const Text('Duplicate Case'),
                onTap: () {
                  Navigator.pop(context);
                  // Duplicate case
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Archive Case'),
                onTap: () {
                  Navigator.pop(context);
                  // Archive case
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete Case'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(context, caseItem);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Case caseItem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Case'),
          content: Text(
            'Are you sure you want to delete "${caseItem.title}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Delete case
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddNoteDialog(BuildContext context, Case caseItem) {
    final noteController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              hintText: 'Enter note...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  Navigator.pop(context);
                  // Add note
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note added successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Add Note'),
            ),
          ],
        );
      },
    );
  }
}
