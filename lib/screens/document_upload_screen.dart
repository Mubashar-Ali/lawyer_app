import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/document_provider.dart';

class DocumentUploadScreen extends StatefulWidget {
  final String? caseId;
  final String? clientId;
  final String? caseName;
  final String? clientName;
  final String category;

  const DocumentUploadScreen({
    super.key,
    this.caseId,
    this.clientId,
    this.caseName,
    this.clientName,
    this.category = 'general',
  });

  @override
  _DocumentUploadScreenState createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  File? _selectedFile;
  String _fileName = '';
  String _fileSize = '';
  String _fileType = '';
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadError;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'jpg',
          'jpeg',
          'png',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'zip',
        ],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;

          // Calculate file size
          final bytes = _selectedFile!.lengthSync();
          if (bytes < 1024 * 1024) {
            _fileSize = '${(bytes / 1024).toStringAsFixed(1)} KB';
          } else {
            _fileSize = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
          }

          // Get file type
          _fileType = result.files.single.extension?.toUpperCase() ?? '';

          // Clear any previous errors
          _uploadError = null;
        });
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Error selecting file: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadDocument() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a file to upload'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadError = null;
    });

    try {
      final documentProvider = Provider.of<DocumentProvider>(
        context,
        listen: false,
      );

      // Determine the category based on whether we have a caseId or clientId
      // If we have a caseId, set category to 'case', otherwise 'client'
      final String category = widget.caseId != null ? 'case' : widget.category;

      // Simulate upload progress
      final progressTimer = Stream.periodic(
        Duration(milliseconds: 100),
        (i) => i,
      ).take(10).listen((i) {
        if (mounted) {
          setState(() {
            _uploadProgress = (i + 1) / 10;
          });
        }
      });

      // Upload the document with explicit error handling
      try {
        print('Starting document upload process');
        final document = await documentProvider.uploadDocument(
          _selectedFile!,
          caseId: widget.caseId,
          clientId: widget.clientId,
          category: category, // Pass the determined category
        );

        print('Document saved locally, ID: ${document.id}');

        // Cancel the timer if it's still active
        progressTimer.cancel();

        if (mounted) {
          setState(() {
            _isUploading = false;
            _uploadProgress = 1.0;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Document saved successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Wait a moment to show the completed progress
          await Future.delayed(Duration(milliseconds: 500));

          Navigator.pop(
            context,
            true,
          ); // Return true to indicate successful upload
        }
      } catch (uploadError) {
        // Handle upload-specific errors
        progressTimer.cancel();

        print('Upload error: $uploadError');

        if (mounted) {
          setState(() {
            _isUploading = false;
            _uploadError = 'Save failed: ${uploadError.toString()}';
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving document: ${uploadError.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      // Handle other errors
      print('General error: $error');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
          _uploadError = 'Error: ${error.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're uploading to a case or client
    final String uploadContext = widget.caseId != null ? 'Case' : 'Client';
    final String uploadName =
        widget.caseId != null
            ? (widget.caseName ?? 'Case')
            : (widget.clientName ?? 'Client');
    final IconData contextIcon =
        widget.caseId != null ? Icons.gavel : Icons.person;

    return Scaffold(
      appBar: AppBar(title: Text('Save Document'), elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show case or client information
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(contextIcon, color: Color(0xFF1A237E)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            uploadContext,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(height: 4),
                          Text(
                            uploadName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Information card about local storage
            Card(
              elevation: 1,
              color: Colors.blue[50],
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
                        Icon(Icons.info_outline, color: Color(0xFF1A237E)),
                        SizedBox(width: 12),
                        Text(
                          'Local Storage Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Documents are saved locally on your device. They will be available even when offline.',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),
            Text(
              'Select Document',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: _isLoading ? null : _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        _selectedFile != null
                            ? Color(0xFF1A237E)
                            : Colors.grey[300]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedFile != null
                          ? Icons.check_circle
                          : Icons.file_upload,
                      size: 48,
                      color:
                          _selectedFile != null
                              ? Color(0xFF1A237E)
                              : Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      _selectedFile != null
                          ? 'File Selected'
                          : 'Tap to select a file',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            _selectedFile != null
                                ? Color(0xFF1A237E)
                                : Colors.grey[600],
                      ),
                    ),
                    if (_selectedFile == null)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'PDF, DOC, DOCX, JPG, PNG, XLS, XLSX, PPT, PPTX, TXT, ZIP',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_selectedFile != null) ...[
              SizedBox(height: 24),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'File Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _fileName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Type: $_fileType',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.data_usage,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Size: $_fileSize',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            widget.caseId != null ? Icons.gavel : Icons.people,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Category: ${widget.caseId != null ? 'Case' : 'General'}',
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
            ],
            if (_isUploading) ...[
              SizedBox(height: 24),
              Text(
                'Saving...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A237E)),
              ),
              SizedBox(height: 8),
              Text(
                '${(_uploadProgress * 100).toInt()}%',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            if (_uploadError != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Error',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      _uploadError!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1A237E).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed:
                    _isLoading || _selectedFile == null
                        ? null
                        : _uploadDocument,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child:
                    _isLoading && !_isUploading
                        ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'SAVE DOCUMENT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
