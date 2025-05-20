import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
import '../providers/case_provider.dart';
import '../providers/client_provider.dart';
import '../widgets/custom_text_field.dart';

class AddEventScreen extends StatefulWidget {
  final EventModel? event;
  final String? caseId;
  final String? clientId;

  const AddEventScreen({
    super.key,
    this.event,
    this.caseId,
    this.clientId,
  });

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _eventType = 'meeting';
  String? _selectedCaseId;
  String? _selectedClientId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // If editing an existing event, populate the form
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _locationController.text = widget.event!.location;
      _selectedDate = widget.event!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.event!.dateTime);
      _eventType = widget.event!.eventType;
      _selectedCaseId = widget.event!.caseId;
      _selectedClientId = widget.event!.clientId;
    }
    
    // If creating from a case or client screen, pre-select that case/client
    if (widget.caseId != null) {
      _selectedCaseId = widget.caseId;
    }
    
    if (widget.clientId != null) {
      _selectedClientId = widget.clientId;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1A237E),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1A237E),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final caseProvider = Provider.of<CaseProvider>(context, listen: false);
      final clientProvider = Provider.of<ClientProvider>(context, listen: false);
      
      // Get case and client details if selected
      String? caseTitle;
      String? clientName;
      
      if (_selectedCaseId != null) {
        final caseData = caseProvider.getCaseById(_selectedCaseId!);
        if (caseData != null) {
          caseTitle = caseData.title;
          // If client not explicitly selected, use the case's client
          if (_selectedClientId == null) {
            _selectedClientId = caseData.clientId;
            clientName = caseData.clientName;
          }
        }
      }
      
      if (_selectedClientId != null && clientName == null) {
        final client = clientProvider.getClientById(_selectedClientId!);
        if (client != null) {
          clientName = client.name;
        }
      }
      
      // Combine date and time
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      final event = EventModel(
        id: widget.event?.id ?? '', // Will be ignored for new events
        title: _titleController.text,
        description: _descriptionController.text,
        dateTime: dateTime,
        location: _locationController.text,
        caseId: _selectedCaseId,
        clientId: _selectedClientId,
        caseTitle: caseTitle,
        clientName: clientName,
        eventType: _eventType,
      );
      
      if (widget.event == null) {
        // Create new event
        await eventProvider.addEvent(event);
      } else {
        // Update existing event
        await eventProvider.updateEvent(event);
      }
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving event: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);
    final clientProvider = Provider.of<ClientProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
        actions: [
          if (widget.event != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Event'),
                    content: Text('Are you sure you want to delete this event?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  try {
                    await Provider.of<EventProvider>(context, listen: false)
                        .deleteEvent(widget.event!.id);
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting event: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _titleController,
                      labelText: 'Title',
                      hintText: 'Enter event title',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      labelText: 'Description',
                      hintText: 'Enter event description',
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    Text('Event Type', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text('Meeting'),
                          selected: _eventType == 'meeting',
                          onSelected: (selected) {
                            setState(() {
                              _eventType = 'meeting';
                            });
                          },
                        ),
                        ChoiceChip(
                          label: Text('Hearing'),
                          selected: _eventType == 'hearing',
                          onSelected: (selected) {
                            setState(() {
                              _eventType = 'hearing';
                            });
                          },
                        ),
                        ChoiceChip(
                          label: Text('Deadline'),
                          selected: _eventType == 'deadline',
                          onSelected: (selected) {
                            setState(() {
                              _eventType = 'deadline';
                            });
                          },
                        ),
                        ChoiceChip(
                          label: Text('Other'),
                          selected: _eventType == 'other',
                          onSelected: (selected) {
                            setState(() {
                              _eventType = 'other';
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                DateFormat('MMM d, yyyy').format(_selectedDate),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Time',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _selectedTime.format(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: _locationController,
                      labelText: 'Location',
                      hintText: 'Enter event location',
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Related Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      decoration: InputDecoration(
                        labelText: 'Related Case',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCaseId,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...caseProvider.cases.map((caseData) {
                          return DropdownMenuItem<String?>(
                            value: caseData.id,
                            child: Text(caseData.title),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCaseId = value;
                          // If case changes, update client if needed
                          if (value != null) {
                            final caseData = caseProvider.getCaseById(value);
                            if (caseData != null) {
                              _selectedClientId = caseData.clientId;
                            }
                          }
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      decoration: InputDecoration(
                        labelText: 'Related Client',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedClientId,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...clientProvider.clients.map((client) {
                          return DropdownMenuItem<String?>(
                            value: client.id,
                            child: Text(client.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedClientId = value;
                        });
                      },
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveEvent,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(widget.event == null ? 'Create Event' : 'Update Event'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
