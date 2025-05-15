import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/providers/appointment_provider.dart';
import '../../../../core/models/appointment.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/appointment_card.dart';

class LawyerCalendarScreen extends StatefulWidget {
  const LawyerCalendarScreen({super.key});

  @override
  State<LawyerCalendarScreen> createState() => _LawyerCalendarScreenState();
}

class _LawyerCalendarScreenState extends State<LawyerCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final appointments = appointmentProvider.appointments;
    
    // Get appointments for selected day
    final selectedDayAppointments = appointments.where((appointment) {
      return isSameDay(appointment.startTime, _selectedDay);
    }).toList();
    
    // Sort appointments by start time
    selectedDayAppointments.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: appointmentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCalendar(appointments),
                const SizedBox(height: 8),
                _buildDayHeader(),
                Expanded(
                  child: selectedDayAppointments.isEmpty
                      ? _buildEmptyState()
                      : _buildAppointmentsList(selectedDayAppointments),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendar(List<Appointment> appointments) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      eventLoader: (day) {
        return appointments.where((appointment) => isSameDay(appointment.startTime, day)).toList();
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarStyle: CalendarStyle(
        markersMaxCount: 3,
        markerDecoration: BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonShowsNext: false,
        titleCentered: true,
      ),
    );
  }

  Widget _buildDayHeader() {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dateFormat.format(_selectedDay!),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            '${_getAppointmentsForDay(_selectedDay!).length} Appointments',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    return appointmentProvider.appointments.where((appointment) {
      return isSameDay(appointment.startTime, day);
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No appointments for this day',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Schedule a new appointment',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to add appointment screen
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Appointment'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return AppointmentCard(
          appointment: appointments[index],
          onTap: () {
            // Navigate to appointment details
          },
        );
      },
    );
  }
}
