import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/case_model.dart';
import '../providers/case_provider.dart';
import '../widgets/custom_text_field.dart';
import '../utils/date_formatter.dart';

class AddCaseScreen extends StatefulWidget {
  final CaseModel? caseToEdit;

  const AddCaseScreen({super.key, this.caseToEdit});

  @override
  _AddCaseScreenState createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _caseNumberController = TextEditingController();
  final _courtController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _clientNameController = TextEditingController();

  String _selectedClientId = '';
  String _selectedCaseType = 'Civil';
  String _selectedStatus = 'Active';
  DateTime _filingDate = DateTime.now();
  DateTime? _nextHearing;

  bool _isLoading = false;

  final List<String> _caseTypes = [
    'Civil',
    'Criminal',
    'Family',
    'Corporate',
    'Real Estate',
    'Intellectual Property',
    'Tax',
    'Immigration',
    'Labor',
    'Other',
  ];

  final List<String> _statusOptions = [
    'Active',
    'Pending',
    'Closed',
    'On Hold',
  ];

  @override
  void initState() {
    super.initState();

    // If editing an existing case, populate the form
    if (widget.caseToEdit != null) {
      _titleController.text = widget.caseToEdit!.title;
      _caseNumberController.text = widget.caseToEdit!.caseNumber;
      _courtController.text = widget.caseToEdit!.court;
      _descriptionController.text = widget.caseToEdit!.description;
      _clientNameController.text = widget.caseToEdit!.clientName;

      _selectedClientId = widget.caseToEdit!.clientId;
      _selectedCaseType = widget.caseToEdit!.caseType;
      _selectedStatus = widget.caseToEdit!.status;

      // Parse filing date
      try {
        _filingDate = widget.caseToEdit?.filingDate ?? DateTime.now();
      } catch (e) {
        // If parsing fails, use current date
        _filingDate = DateTime.now();
      }

      // Parse next hearing date if available
      if (widget.caseToEdit!.nextHearing != null) {
        try {
          _nextHearing = widget.caseToEdit?.nextHearing;
        } catch (e) {
          _nextHearing = null;
        }
      }
    }
    
    // Check if we have client information from route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        if (args.containsKey('clientId') && args.containsKey('clientName')) {
          setState(() {
            _selectedClientId = args['clientId'];
            _clientNameController.text = args['clientName'];
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _caseNumberController.dispose();
    _courtController.dispose();
    _descriptionController.dispose();
    _clientNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFilingDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isFilingDate ? _filingDate : (_nextHearing ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1A237E),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFilingDate) {
          _filingDate = picked;
        } else {
          _nextHearing = picked;
        }
      });
    }
  }

  Future<void> _saveCase() async {
    if (!_formKey.currentState!.validate()) return;

    if (_clientNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a client name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final caseProvider = Provider.of<CaseProvider>(context, listen: false);

      // For new cases, generate a unique client ID if not provided
      if (_selectedClientId.isEmpty) {
        _selectedClientId = DateTime.now().millisecondsSinceEpoch.toString();
      }

      final caseData = CaseModel(
        id: widget.caseToEdit?.id ?? '',
        title: _titleController.text.trim(),
        caseNumber: _caseNumberController.text.trim(),
        clientName: _clientNameController.text.trim(),
        clientId: _selectedClientId,
        caseType: _selectedCaseType,
        court: _courtController.text.trim(),
        status: _selectedStatus,
        filingDate: _filingDate, // Pass DateTime directly
        nextHearing: _nextHearing, // Pass DateTime directly
        description: _descriptionController.text.trim(),
        documentIds: widget.caseToEdit?.documentIds,
      );

      if (widget.caseToEdit == null) {
        // Add new case
        await caseProvider.addCase(caseData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Case added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Update existing case
        await caseProvider.updateCase(caseData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Case updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.caseToEdit == null ? 'Add New Case' : 'Edit Case'),
        elevation: 0,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Case Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      SizedBox(height: 24),
                      CustomTextField(
                        controller: _titleController,
                        labelText: 'Case Title',
                        hintText: 'Enter case title',
                        prefixIcon: Icons.title,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a case title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        controller: _caseNumberController,
                        labelText: 'Case Number',
                        hintText: 'Enter case number',
                        prefixIcon: Icons.numbers,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a case number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        controller: _clientNameController,
                        labelText: 'Client Name',
                        hintText: 'Enter client name',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a client name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'Case Type',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                              color: Colors.white,
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedCaseType,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.category,
                                  color: Colors.grey[600],
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey[600],
                              ),
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              items:
                                  _caseTypes.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCaseType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        controller: _courtController,
                        labelText: 'Court',
                        hintText: 'Enter court name',
                        prefixIcon: Icons.gavel,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the court name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                              color: Colors.white,
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.flag,
                                  color: Colors.grey[600],
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey[600],
                              ),
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              items:
                                  _statusOptions.map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'Filing Date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _selectDate(context, true),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.grey[600],
                                    size: 22,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    DateFormatter.toDisplayDate(_filingDate),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'Next Hearing Date (Optional)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _selectDate(context, false),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event,
                                    color: Colors.grey[600],
                                    size: 22,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    _nextHearing == null
                                        ? 'Select Date (Optional)'
                                        : DateFormatter.toDisplayDate(
                                          _nextHearing!,
                                        ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          _nextHearing == null
                                              ? Colors.grey[400]
                                              : Colors.black87,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Text(
                        'Case Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      SizedBox(height: 16),
                      CustomTextField(
                        controller: _descriptionController,
                        hintText: 'Enter case description and details...',
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a case description';
                          }
                          return null;
                        },
                      ),
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
                          onPressed: _saveCase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            widget.caseToEdit == null
                                ? 'ADD CASE'
                                : 'UPDATE CASE',
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
              ),
    );
  }
}
