import 'package:flutter/material.dart';
import 'package:lawyer_app/models/document_model.dart';

class DocumentItem extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onMenuPressed;

  const DocumentItem({
    super.key,
    required this.document,
    required this.onTap,
    this.onDelete,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Document icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: document.getTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  document.getIconData(),
                  color: document.getTypeColor(),
                  size: 24,
                ),
              ),
              SizedBox(width: 12),

              // Document details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        // File type
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: document.getTypeColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            document.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: document.getTypeColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),

                        // Category chip
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                document.category == 'case'
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                document.category.toLowerCase() == 'case'
                                    ? Icons.gavel
                                    : document.category.toLowerCase() ==
                                        'client'
                                    ? Icons.people
                                    : Icons
                                        .insert_drive_file, // for 'General' or any fallback
                                size: 10,
                                color:
                                    document.category.toLowerCase() == 'case'
                                        ? Colors.blue
                                        : document.category.toLowerCase() ==
                                            'client'
                                        ? Colors.green
                                        : Colors
                                            .grey, // neutral color for general
                              ),

                              SizedBox(width: 4),
                              Text(
                                document.category.toLowerCase() == 'case'
                                    ? 'Case'
                                    : document.category.toLowerCase() ==
                                        'client'
                                    ? 'Client'
                                    : 'General',
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      document.category.toLowerCase() == 'case'
                                          ? Colors.blue
                                          : document.category.toLowerCase() ==
                                              'client'
                                          ? Colors.green
                                          : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 8),

                        // File size
                        Text(
                          document.size,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      document.uploadDateRelative,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Menu button
              // Delete button (always shown if onDelete is provided)
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: onDelete,
                  color: Colors.redAccent,
                  splashRadius: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
