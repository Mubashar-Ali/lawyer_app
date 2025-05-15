class AppConstants {
  // App Info
  static const String appName = 'LegalPro';
  static const String appVersion = '1.0.0';

  // Auth Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';

  // Lawyer Routes
  static const String lawyerDashboardRoute = '/lawyer/dashboard';
  static const String lawyerCasesRoute = '/lawyer/cases';
  static const String lawyerClientsRoute = '/lawyer/clients';
  static const String lawyerCalendarRoute = '/lawyer/calendar';
  static const String lawyerTasksRoute = '/lawyer/tasks';
  static const String lawyerDocumentsRoute = '/lawyer/documents';
  static const String lawyerProfileRoute = '/lawyer/profile';

  // Lawyer Detail Routes
  static const String lawyerCaseDetailRoute = '/lawyer/cases/:id';
  static const String lawyerClientDetailRoute = '/lawyer/clients/:id';
  static const String lawyerAppointmentDetailRoute = '/lawyer/appointments/:id';
  static const String lawyerTaskDetailRoute = '/lawyer/tasks/:id';
  static const String lawyerDocumentDetailRoute = '/lawyer/documents/:id';

  // Lawyer Add Routes
  static const String lawyerAddCaseRoute = '/lawyer/cases/add';
  static const String lawyerAddClientRoute = '/lawyer/clients/add';
  static const String lawyerAddAppointmentRoute = '/lawyer/appointments/add';
  static const String lawyerAddTaskRoute = '/lawyer/tasks/add';
  static const String lawyerAddDocumentRoute = '/lawyer/documents/add';

  // Client Routes
  static const String clientDashboardRoute = '/client/dashboard';
  static const String clientCasesRoute = '/client/cases';
  static const String clientDocumentsRoute = '/client/documents';
  static const String clientAppointmentsRoute = '/client/appointments';
  static const String clientPaymentsRoute = '/client/payments';
  static const String clientProfileRoute = '/client/profile';

  // Client Detail Routes
  static const String clientCaseDetailRoute = '/client/cases/:id';
  static const String clientAppointmentDetailRoute = '/client/appointments/:id';
  static const String clientDocumentDetailRoute = '/client/documents/:id';
  static const String clientPaymentDetailRoute = '/client/payments/:id';

  // Case status options
  static const List<String> caseStatusOptions = ['Active', 'Pending', 'Completed', 'Archived'];
  
  // Case type options
  static const List<String> caseTypeOptions = [
    'Personal Injury',
    'Family Law',
    'Criminal Defense',
    'Real Estate',
    'Business Law',
    'Intellectual Property',
    'Immigration',
    'Probate',
    'Contract Law',
    'Other'
  ];
  
  // Appointment type options
  static const List<String> appointmentTypeOptions = [
    'Consultation',
    'Court Appearance',
    'Deposition',
    'Document Review',
    'Mediation',
    'Negotiation',
    'Preparation',
    'Strategy',
    'Other'
  ];
  
  // Task priority options
  static const List<String> taskPriorityOptions = ['Low', 'Medium', 'High', 'Urgent'];
}
