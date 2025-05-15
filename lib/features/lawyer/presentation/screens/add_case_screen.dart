import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lawyer_app/core/theme/app_theme.dart';
import 'package:lawyer_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/case_provider.dart';
import '../../../../core/providers/client_provider.dart';
import '../../../../core/models/case.dart';


class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});

  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _caseNumberController = TextEditingController();
  final _courtController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _caseTypeController = TextEditingController();
  
  String? _selectedClientId;
  DateTime _filingDate = DateTime.now();
  DateTime _nextHearing = DateTime.now().add(const Duration(days: 30));
  String _status = 'Active';
  final List<String> _tags = [];
  final _tagController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  final List<String> _statusOptions = ['Active', 'Pending', 'Completed'];
  final List<String> _caseTypeOptions = [
    'Personal Injury',
    'Family Law',
    'Criminal Defense',
    'Estate Planning',
    'Business Law',
    'Intellectual Property',
    'Real Estate',
    'Immigration',
    'Employment',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _caseNumberController.dispose();
    _courtController.dispose();
    _descriptionController.dispose();
    _caseTypeController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFilingDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFilingDate ? _filingDate : _nextHearing,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveCase() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    if (_selectedClientId == null) {
      setState(() {
        _errorMessage = 'Please select a client';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final clientProvider = Provider.of<ClientProvider>(context, listen: false);
      final client = clientProvider.getClientById(_selectedClientId!);
      
      if (client == null) {
        throw Exception('Selected client not found');
      }

      final newCase = Case(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        caseNumber: _caseNumberController.text.trim(),
        clientId: _selectedClientId!,
        clientName: client.name,
        court: _courtController.text.trim(),
        status: _status,
        filingDate: _filingDate,
        nextHearing: _nextHearing,
        description: _descriptionController.text.trim(),
        caseType: _caseTypeController.text.trim(),
        tags: _tags,
      );

      final caseProvider = Provider.of<CaseProvider>(context, listen: false);
      final success = await caseProvider.addCase(newCase);

      if (!mounted) return;

      if (success) {
        context.pop();
      } else {
        setState(() {
          _errorMessage = caseProvider.errorMessage ?? 'Failed to add case. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
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
    final clientProvider = Provider.of<ClientProvider>(context);
    final clients = clientProvider.clients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Case'),
        centerTitle: true,
      ),
      body: clientProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Error Message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Case Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Case Title',
                      hintText: 'Enter case title',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a case title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Case Number
                  TextFormField(
                    controller: _caseNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Case Number',
                      hintText: 'Enter case number',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a case number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Client Selection
                  DropdownButtonFormField<String>(
                    value: _selectedClientId,
                    decoration: const InputDecoration(
                      labelText: 'Client',
                      hintText: 'Select client',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: clients.map((client) {
                      return DropdownMenuItem<String>(
                        value: client.id,
                        child: Text(client.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClientId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a client';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Court
                  TextFormField(
                    controller: _courtController,
                    decoration: const InputDecoration(
                      labelText: 'Court',
                      hintText: 'Enter court name',
                      prefixIcon: Icon(Icons.gavel),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a court name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Status
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      hintText: 'Select status',
                      prefixIcon: Icon(Icons.pending_actions),
                    ),
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _status = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Filing Date
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Filing Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('MMM d, yyyy').format(_filingDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Next Hearing
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Next Hearing Date',
                        prefixIcon: Icon(Icons.event),
                      ),
                      child: Text(
                        DateFormat('MMM d, yyyy').format(_nextHearing),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Case Type
                  TextFormField(
                    controller: _caseTypeController,
                    decoration: InputDecoration(
                      labelText: 'Case Type',
                      hintText: 'Enter case type',
                      prefixIcon: const Icon(Icons.category),
                      suffixIcon: PopupMenuButton<String>(
                        icon: const Icon(Icons.arrow_drop_down),
                        onSelected: (value) {
                          _caseTypeController.text = value;
                        },
                        itemBuilder: (context) {
                          return _caseTypeOptions.map((type) {
                            return PopupMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a case type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter case description',
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tags',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tagController,
                              decoration: const InputDecoration(
                                hintText: 'Add a tag',
                                prefixIcon: Icon(Icons.tag),
                              ),
                              onFieldSubmitted: (_) => _addTag(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _addTag,
                            icon: const Icon(Icons.add),
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeTag(tag),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  AuthButton(
                    text: 'Save Case',
                    isLoading: _isLoading,
                    onPressed: _saveCase,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
