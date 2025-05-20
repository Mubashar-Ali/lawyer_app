import 'package:flutter/material.dart';
import '../models/case_model.dart';

class CaseListItem extends StatelessWidget {
  final CaseModel caseItem;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CaseListItem({
    super.key,
    required this.caseItem,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Closed':
        return Colors.grey;
      case 'On Hold':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(caseItem.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      caseItem.status,
                      style: TextStyle(
                        color: _getStatusColor(caseItem.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Case #${caseItem.caseNumber}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                caseItem.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    caseItem.clientName,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.category, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(caseItem.caseType, style: TextStyle(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.gavel, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(caseItem.court, style: TextStyle(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Filed: ${caseItem.filingDateFormatted}',
                            style: TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (caseItem.nextHearing != null) ...[
                    SizedBox(width: 16),
                    Flexible(
                      child: Row(
                        children: [
                          Icon(Icons.event, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Hearing: ${caseItem.nextHearingFormatted}',
                              style: TextStyle(color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if (caseItem.hasDocuments)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.attach_file, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        '${caseItem.documentCount} document${caseItem.documentCount != 1 ? 's' : ''}',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Color(0xFF1A237E)),
                    onPressed: onEdit,
                    tooltip: 'Edit case',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Delete case',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
