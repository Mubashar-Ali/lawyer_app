import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/document_model.dart';
import '../widgets/loading_indicator.dart';
import 'package:open_file/open_file.dart';

class DocumentViewScreen extends StatefulWidget {
  final DocumentModel document;

  const DocumentViewScreen({
    super.key,
    required this.document,
  });

  @override
  _DocumentViewScreenState createState() => _DocumentViewScreenState();
}

class _DocumentViewScreenState extends State<DocumentViewScreen> {
  bool _isLoading = true;
  String? _localFilePath;
  String? _errorMessage;
  bool _isDownloading = false;
  int _totalPages = 0;
  int _currentPage = 0;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if document is local or remote
      if (widget.document.isLocal) {
        // For local documents, just use the path directly
        final filePath = widget.document.url.replaceFirst('file://', '');
        final file = File(filePath);
        
        if (await file.exists()) {
          setState(() {
            _localFilePath = filePath;
            _isLoading = false;
          });
        } else {
          throw Exception('Local file not found: $filePath');
        }
      } else if (widget.document.isPdf) {
        await _loadPdf();
      } else if (widget.document.isImage) {
        // Images are handled directly in the build method
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Preview not available for ${widget.document.type} files. Please download the file to view it.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading document: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPdf() async {
    try {
      // If it's a remote URL
      if (widget.document.url.startsWith('http')) {
        final url = widget.document.url;
        final response = await http.get(Uri.parse(url));
        
        if (response.statusCode == 200) {
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/${widget.document.name}');
          await file.writeAsBytes(response.bodyBytes);
          
          setState(() {
            _localFilePath = file.path;
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load PDF: ${response.statusCode}');
        }
      } else {
        // For local files
        final filePath = widget.document.url.replaceFirst('file://', '');
        setState(() {
          _localFilePath = filePath;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading PDF: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _openDocument() async {
    try {
      String filePath;
      
      if (widget.document.isLocal) {
        // For local documents, just use the path directly
        filePath = widget.document.url.replaceFirst('file://', '');
      } else {
        // For remote documents, download first
        await _downloadDocument();
        filePath = _localFilePath!;
      }
      
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening document: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening document: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _downloadDocument() async {
    if (widget.document.isLocal) {
      // For local documents, just return the path
      return widget.document.url.replaceFirst('file://', '');
    }
    
    setState(() {
      _isDownloading = true;
    });

    try {
      final url = widget.document.url;
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${widget.document.name}');
        await file.writeAsBytes(response.bodyBytes);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return the file path for sharing
        setState(() {
          _localFilePath = file.path;
          _isDownloading = false;
        });
        
        return file.path;
      } else {
        throw Exception('Failed to download document: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading document: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> _shareDocument() async {
    try {
      setState(() {
        _isDownloading = true;
      });
      
      String? filePath;
      
      if (widget.document.isLocal) {
        // For local documents, just use the path directly
        filePath = widget.document.url.replaceFirst('file://', '');
      } else if (_localFilePath != null) {
        filePath = _localFilePath!;
      } else {
        filePath = await _downloadDocument();
      }
      
      if (filePath == null) {
        throw Exception('Failed to get document for sharing');
      }
      
      setState(() {
        _isDownloading = false;
      });
      
      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Sharing ${widget.document.name}',
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing document: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _goToPage(int page) {
    if (_pdfViewController != null && page >= 0 && page < _totalPages) {
      _pdfViewController!.setPage(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.name),
        actions: [
          if (!_isLoading && _errorMessage == null)
            IconButton(
              icon: Icon(Icons.share),
              onPressed: _isDownloading ? null : _shareDocument,
              tooltip: 'Share document',
            ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _isDownloading || widget.document.isLocal ? null : _downloadDocument,
            tooltip: widget.document.isLocal ? 'Document is stored locally' : 'Download document',
          ),
          if (!_isLoading && _errorMessage == null)
            IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: _isDownloading ? null : _openDocument,
              tooltip: 'Open with default app',
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: LoadingIndicator(message: 'Loading document...'))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 24),
                        if (!widget.document.isLocal)
                          ElevatedButton(
                            onPressed: _downloadDocument,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1A237E),
                              foregroundColor: Colors.white,
                            ),
                            child: Text('DOWNLOAD DOCUMENT'),
                          ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _openDocument,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                          ),
                          child: Text('OPEN WITH DEFAULT APP'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildDocumentViewer(),
      bottomNavigationBar: _isLoading || _errorMessage != null || !widget.document.isPdf || _localFilePath == null
          ? null
          : BottomAppBar(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page $_currentPage of $_totalPages',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: _currentPage > 1
                              ? () => _goToPage(_currentPage - 2)
                              : null,
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: _currentPage < _totalPages
                              ? () => _goToPage(_currentPage)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDocumentViewer() {
    if (widget.document.isPdf && _localFilePath != null) {
      return PDFView(
        filePath: _localFilePath!,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageFling: true,
        pageSnap: true,
        onRender: (pages) {
          setState(() {
            _totalPages = pages!;
          });
        },
        onPageChanged: (page, total) {
          setState(() {
            _currentPage = page! + 1;
            _totalPages = total!;
          });
        },
        onError: (error) {
          setState(() {
            _errorMessage = error.toString();
          });
        },
        onViewCreated: (controller) {
          _pdfViewController = controller;
        },
      );
    } else if (widget.document.isImage) {
      if (widget.document.isLocal) {
        // For local images
        final filePath = widget.document.url.replaceFirst('file://', '');
        return Center(
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4,
            child: Image.file(
              File(filePath),
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorView(error.toString());
              },
            ),
          ),
        );
      } else {
        // For remote images
        return Center(
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4,
            child: Image.network(
              widget.document.url,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorView(error.toString());
              },
            ),
          ),
        );
      }
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.document.getIconData(),
              size: 64,
              color: widget.document.getTypeColor(),
            ),
            SizedBox(height: 16),
            Text(
              widget.document.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${widget.document.type} • ${widget.document.size}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (widget.document.isLocal)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Chip(
                  label: Text('STORED LOCALLY'),
                  backgroundColor: Colors.green[100],
                  labelStyle: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _openDocument,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: Text('OPEN WITH DEFAULT APP'),
            ),
            if (!widget.document.isLocal)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ElevatedButton(
                  onPressed: _downloadDocument,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('DOWNLOAD DOCUMENT'),
                ),
              ),
          ],
        ),
      );
    }
  }

  Widget _buildErrorView(String errorMessage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
        SizedBox(height: 16),
        Text(
          'Error loading document: $errorMessage',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: _openDocument,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1A237E),
            foregroundColor: Colors.white,
          ),
          child: Text('OPEN WITH DEFAULT APP'),
        ),
      ],
    );
  }
}
