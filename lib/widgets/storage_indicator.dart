import 'package:flutter/material.dart';

class StorageIndicator extends StatelessWidget {
  final bool isOffline;

  const StorageIndicator({
    super.key,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: isOffline ? Colors.orange[50] : Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOffline ? Icons.phone_android : Icons.cloud_upload,
                  color: isOffline ? Colors.orange[700] : Colors.blue[700],
                ),
                SizedBox(width: 12),
                Text(
                  isOffline ? 'Local Storage Mode' : 'Cloud Storage Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isOffline ? Colors.orange[700] : Colors.blue[700],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              isOffline
                  ? 'You are currently offline. Documents will be saved locally on your device and synced to the cloud when you reconnect.'
                  : 'Documents will be uploaded to secure cloud storage and available across all your devices.',
              style: TextStyle(
                color: isOffline ? Colors.orange[800] : Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
