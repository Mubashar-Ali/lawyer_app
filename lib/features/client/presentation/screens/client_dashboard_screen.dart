import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/case_provider.dart';
import '../../../../core/providers/appointment_provider.dart';
import '../../../../core/providers/document_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../core/models/appointment.dart';
import '../../../../core/models/case.dart';
import '../../../../core/models/document.dart';

import '../widgets/notification_badge.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final documentProvider = Provider.of<DocumentProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    // Filter for client's data (in a real app, this would be based on the logged-in client's ID)
    final clientId = '1'; // Example client ID
    final clientCases = caseProvider.cases.where((c) => c.clientId == clientId).toList();
    final clientAppointments = appointmentProvider.appointments.where((a) => a.clientId == clientId).toList();
    final clientDocuments = documentProvider.documents.where((d) => d.clientId == clientId && d.isSharedWithClient).toList();

    // Sort appointments by date
    clientAppointments.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Get upcoming appointments (next 7 days)
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    final upcomingAppointments = clientAppointments.where((a) => 
      a.startTime.isAfter(now) && a.startTime.isBefore(nextWeek)
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
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
      body: caseProvider.isLoading || appointmentProvider.isLoading || documentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  caseProvider.loadCases(),
                  appointmentProvider.loadAppointments(),
                  documentProvider.loadDocuments(),
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
                    _buildStatusCards(clientCases, upcomingAppointments, clientDocuments),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      'Upcoming Appointments',
                      'View All',
                      () => context.go(AppConstants.clientAppointmentsRoute),
                    ),
                    const SizedBox(height: 16),
                    _buildAppointmentsList(upcomingAppointments),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      'My Cases',
                      'View All',
                      () => context.go(AppConstants.clientCasesRoute),
                    ),
                    const SizedBox(height: 16),
                    _buildCasesList(clientCases),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      'Recent Documents',
                      'View All',
                      () => context.go(AppConstants.clientDocumentsRoute),
                    ),
                    const SizedBox(height: 16),
                    _buildDocumentsList(clientDocuments),
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
          '$greeting, Robert',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here\'s an update on your legal matters',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCards(List<Case> cases, List<Appointment> appointments, List<Document> documents) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatusCard(
          'Active Cases',
          cases.length.toString(),
          Icons.gavel,
          Colors.blue,
          () => context.go(AppConstants.clientCasesRoute),
        ),
        _buildStatusCard(
          'Upcoming Appointments',
          appointments.length.toString(),
          Icons.calendar_today,
          Colors.green,
          () => context.go(AppConstants.clientAppointmentsRoute),
        ),
        _buildStatusCard(
          'Shared Documents',
          documents.length.toString(),
          Icons.folder_outlined,
          Colors.orange,
          () => context.go(AppConstants.clientDocumentsRoute),
        ),
        _buildStatusCard(
          'Messages',
          '0',
          Icons.message_outlined,
          Colors.purple,
          () {},
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
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

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return _buildEmptyState(
        'No upcoming appointments',
        'Contact your lawyer to schedule an appointment',
        Icons.event_available,
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length > 3 ? 3 : appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final timeFormat = DateFormat('h:mm a');
        final dateFormat = DateFormat('MMM d, yyyy');
        
        final isToday = appointment.startTime.day == DateTime.now().day &&
                        appointment.startTime.month == DateTime.now().month &&
                        appointment.startTime.year == DateTime.now().year;
        
        final dateString = isToday ? 'Today' : dateFormat.format(appointment.startTime);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              // Navigate to appointment details
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time indicator
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          timeFormat.format(appointment.startTime),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateString,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Appointment details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              appointment.isRemote ? Icons.videocam_outlined : Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              appointment.location,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (appointment.caseTitle != null && appointment.caseTitle!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.gavel_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                appointment.caseTitle!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCasesList(List<Case> cases) {
    if (cases.isEmpty) {
      return _buildEmptyState(
        'No active cases',
        'You don\'t have any active cases at the moment',
        Icons.gavel_outlined,
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cases.length > 2 ? 2 : cases.length,
      itemBuilder: (context, index) {
        final caseItem = cases[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              // Navigate to case details
            },
            borderRadius: BorderRadius.circular(12),
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Case #: ${caseItem.caseNumber}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(caseItem.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.balance_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Court: ${caseItem.court}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Type: ${caseItem.caseType}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentsList(List<Document> documents) {
    if (documents.isEmpty) {
      return _buildEmptyState(
        'No documents shared with you',
        'Your lawyer will share relevant documents here',
        Icons.folder_outlined,
      );
    }
    
    // Sort documents by upload date (newest first)
    final sortedDocuments = List<Document>.from(documents);
    sortedDocuments.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedDocuments.length > 3 ? 3 : sortedDocuments.length,
      itemBuilder: (context, index) {
        final document = sortedDocuments[index];
        final dateFormat = DateFormat('MMM d, yyyy');
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              // Navigate to document details or open document
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Document icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getDocumentColor(document.fileType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getDocumentIcon(document.fileType),
                      color: _getDocumentColor(document.fileType),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Document details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatFileSize(document.fileSize)} • ${dateFormat.format(document.uploadDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (document.caseTitle != null && document.caseTitle!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Case: ${document.caseTitle}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Download icon
                  IconButton(
                    icon: const Icon(Icons.download_outlined),
                    onPressed: () {
                      // Download document
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  IconData _getDocumentIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'docx':
      case 'doc':
        return Icons.description_outlined;
      case 'xlsx':
      case 'xls':
        return Icons.table_chart_outlined;
      case 'pptx':
      case 'ppt':
        return Icons.slideshow_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getDocumentColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'docx':
      case 'doc':
        return Colors.blue;
      case 'xlsx':
      case 'xls':
        return Colors.green;
      case 'pptx':
      case 'ppt':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  Widget _buildEmptyState(
    String message,
    String subtitle,
    IconData icon,
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
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
