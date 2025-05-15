import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/case_provider.dart';
import '../../../../core/models/case.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_constants.dart';

class ClientCaseDetailScreen extends StatelessWidget {
  final String caseId;
  
  const ClientCaseDetailScreen({
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
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // Share case details
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
                Icons.message_outlined,
                'Message Lawyer',
                () {
                  // Message lawyer
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Messaging feature coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _buildActionButton(
                context,
                Icons.event_outlined,
                'Schedule Meeting',
                () {
                  // Schedule meeting
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Scheduling feature coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _buildActionButton(
                context,
                Icons.folder_outlined,
                'View Documents',
                () {
                  // View documents
                  Navigator.pushNamed(
                    context,
                    AppConstants.clientDocumentsRoute,
                  );
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
                  'Attorney: ${caseItem.attorneyName ?? 'Your Attorney'}',
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
            _buildDetailRow('Opposing Party', caseItem.opposingParty ?? 'Not specified'),
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
                  Navigator.pushNamed(
                    context,
                    AppConstants.clientAppointmentsRoute,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRelatedItemCard(
                context,
                Icons.folder_outlined,
                'Documents',
                '12 Files',
                Colors.green,
                () {
                  // Navigate to case documents
                  Navigator.pushNamed(
                    context,
                    AppConstants.clientDocumentsRoute,
                  );
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
                Icons.payment_outlined,
                'Payments',
                '2 Invoices',
                Colors.orange,
                () {
                  // Navigate to case payments
                  Navigator.pushNamed(
                    context,
                    AppConstants.clientPaymentsRoute,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRelatedItemCard(
                context,
                Icons.gavel_outlined,
                'Legal Advice',
                'View Advice',
                Colors.purple,
                () {
                  // Show legal advice
                  _showLegalAdviceDialog(context, caseItem);
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

  void _showLegalAdviceDialog(BuildContext context, Case caseItem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Legal Advice'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Important Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Based on the current status of your case, here are some important points to consider:',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  '1. Keep all documentation related to your case organized and accessible.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  '2. Avoid discussing your case with anyone other than your attorney.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  '3. Be prepared for your upcoming court date by reviewing all materials provided by your attorney.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  '4. Notify your attorney immediately of any new developments related to your case.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  'This information is general advice and not specific legal counsel. Please contact your attorney for personalized guidance.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
