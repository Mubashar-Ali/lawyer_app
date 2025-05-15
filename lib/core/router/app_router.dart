import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lawyer_app/core/providers/auth_provider.dart';
import 'package:lawyer_app/core/utils/app_constants.dart';
import 'package:lawyer_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:lawyer_app/features/auth/presentation/screens/login_screen.dart';
import 'package:lawyer_app/features/auth/presentation/screens/register_screen.dart';
import 'package:lawyer_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:lawyer_app/features/client/presentation/screens/client_appointments_screen.dart'
    as client;
import 'package:lawyer_app/features/client/presentation/screens/client_cases_screen.dart'
    as client;
import 'package:lawyer_app/features/client/presentation/screens/client_dashboard_screen.dart'
    as client;
import 'package:lawyer_app/features/client/presentation/screens/client_documents_screen.dart'
    as client;
import 'package:lawyer_app/features/client/presentation/screens/client_main_screen.dart';
import 'package:lawyer_app/features/client/presentation/screens/client_case_detail_screen.dart'
    as client;
import 'package:lawyer_app/features/lawyer/presentation/screens/lawyer_calendar_screen.dart'
    as lawyer;
import 'package:lawyer_app/features/lawyer/presentation/screens/lawyer_case_detail_screen.dart'
    as lawyer;
import 'package:lawyer_app/features/lawyer/presentation/screens/lawyer_cases_screen.dart'
    as lawyer;
import 'package:lawyer_app/features/lawyer/presentation/screens/lawyer_clients_screen.dart'
    as lawyer;
import 'package:lawyer_app/features/lawyer/presentation/screens/lawyer_dashboard_screen.dart'
    as lawyer;
import 'package:lawyer_app/features/lawyer/presentation/screens/lawyer_documents_screen.dart'
    as lawyer;
import 'package:lawyer_app/features/lawyer/presentation/screens/lawyer_main_screen.dart'
    as lawyer;
import 'package:lawyer_app/features/lawyer/presentation/screens/lawyer_profile_screen.dart'
    as lawyer;
import 'package:lawyer_app/features/lawyer/presentation/screens/lawyer_tasks_screen.dart'
    as lawyer;
import 'package:provider/provider.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _lawyerShellNavigatorKey = GlobalKey<NavigatorState>();
  static final _clientShellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.splashRoute,
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      final isInitializing = state.matchedLocation == AppConstants.splashRoute;
      final isAuthRoute =
          state.matchedLocation == AppConstants.loginRoute ||
          state.matchedLocation == AppConstants.registerRoute ||
          state.matchedLocation == AppConstants.forgotPasswordRoute;

      // If the user is not logged in and not on an auth route, redirect to login
      if (!isLoggedIn && !isAuthRoute && !isInitializing) {
        return AppConstants.loginRoute;
      }

      // If the user is logged in and on an auth route, redirect to dashboard
      if (isLoggedIn && isAuthRoute) {
        if (authProvider.isLawyer) {
          return AppConstants.lawyerDashboardRoute;
        } else {
          return AppConstants.clientDashboardRoute;
        }
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: AppConstants.splashRoute,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.loginRoute,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.registerRoute,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.forgotPasswordRoute,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Lawyer Routes
      ShellRoute(
        navigatorKey: _lawyerShellNavigatorKey,
        builder:
            (context, state, child) => lawyer.LawyerMainScreen(child: child),
        routes: [
          GoRoute(
            path: AppConstants.lawyerDashboardRoute,
            builder: (context, state) => const lawyer.LawyerDashboardScreen(),
          ),
          GoRoute(
            path: AppConstants.lawyerCasesRoute,
            builder: (context, state) => const lawyer.LawyerCasesScreen(),
          ),
          GoRoute(
            path: AppConstants.lawyerClientsRoute,
            builder: (context, state) => const lawyer.LawyerClientsScreen(),
          ),
          GoRoute(
            path: AppConstants.lawyerCalendarRoute,
            builder: (context, state) => const lawyer.LawyerCalendarScreen(),
          ),
          GoRoute(
            path: AppConstants.lawyerTasksRoute,
            builder: (context, state) => const lawyer.LawyerTasksScreen(),
          ),
          GoRoute(
            path: AppConstants.lawyerDocumentsRoute,
            builder: (context, state) => const lawyer.LawyerDocumentsScreen(),
          ),
          GoRoute(
            path: AppConstants.lawyerProfileRoute,
            builder: (context, state) => const lawyer.LawyerProfileScreen(),
          ),
        ],
      ),

      // Lawyer Detail Routes
      GoRoute(
        path: AppConstants.lawyerCaseDetailRoute,
        builder: (context, state) {
          final caseId = state.pathParameters['id']!;
          return lawyer.LawyerCaseDetailScreen(caseId: caseId);
        },
      ),
      // GoRoute(
      //   path: AppConstants.lawyerClientDetailRoute,
      //   builder: (context, state) {
      //     final clientId = state.pathParameters['id']!;
      //     return LawyerClientDetailScreen(clientId: clientId);
      //   },
      // ),
      // GoRoute(
      //   path: AppConstants.lawyerAppointmentDetailRoute,
      //   builder: (context, state) {
      //     final appointmentId = state.pathParameters['id']!;
      //     return LawyerAppointmentDetailScreen(appointmentId: appointmentId);
      //   },
      // ),
      // GoRoute(
      //   path: AppConstants.lawyerTaskDetailRoute,
      //   builder: (context, state) {
      //     final taskId = state.pathParameters['id']!;
      //     return LawyerTaskDetailScreen(taskId: taskId);
      //   },
      // ),
      // GoRoute(
      //   path: AppConstants.lawyerDocumentDetailRoute,
      //   builder: (context, state) {
      //     final documentId = state.pathParameters['id']!;
      //     return LawyerDocumentDetailScreen(documentId: documentId);
      //   },
      // ),

      // Lawyer Add Routes
      // GoRoute(
      //   path: AppConstants.lawyerAddCaseRoute,
      //   builder: (context, state) => const LawyerAddCaseScreen(),
      // ),
      // GoRoute(
      //   path: AppConstants.lawyerAddClientRoute,
      //   builder: (context, state) => const LawyerAddClientScreen(),
      // ),
      // GoRoute(
      //   path: AppConstants.lawyerAddAppointmentRoute,
      //   builder: (context, state) => const LawyerAddAppointmentScreen(),
      // ),
      // GoRoute(
      //   path: AppConstants.lawyerAddTaskRoute,
      //   builder: (context, state) => const LawyerAddTaskScreen(),
      // ),
      // GoRoute(
      //   path: AppConstants.lawyerAddDocumentRoute,
      //   builder: (context, state) => const LawyerAddDocumentScreen(),
      // ),

      // Client Routes
      ShellRoute(
        navigatorKey: _clientShellNavigatorKey,
        builder:
            (context, state, child) =>
                ClientMainScreen(location: 'BWP', child: child),
        routes: [
          GoRoute(
            path: AppConstants.clientDashboardRoute,
            builder: (context, state) => const client.ClientDashboardScreen(),
          ),
          GoRoute(
            path: AppConstants.clientCasesRoute,
            builder: (context, state) => const client.ClientCasesScreen(),
          ),
          GoRoute(
            path: AppConstants.clientDocumentsRoute,
            builder: (context, state) => const client.ClientDocumentsScreen(),
          ),
          GoRoute(
            path: AppConstants.clientAppointmentsRoute,
            builder:
                (context, state) => const client.ClientAppointmentsScreen(),
          ),
          // GoRoute(
          //   path: AppConstants.clientPaymentsRoute,
          //   builder: (context, state) => const ClientPaymentsScreen(),
          // ),
          // GoRoute(
          //   path: AppConstants.clientProfileRoute,
          //   builder: (context, state) => const ClientProfileScreen(),
          // ),
        ],
      ),

      // Client Detail Routes
      GoRoute(
        path: AppConstants.clientCaseDetailRoute,
        builder: (context, state) {
          final caseId = state.pathParameters['id']!;
          return client.ClientCaseDetailScreen(caseId: caseId);
        },
      ),
      // GoRoute(
      //   path: AppConstants.clientAppointmentDetailRoute,
      //   builder: (context, state) {
      //     final appointmentId = state.pathParameters['id']!;
      //     return ClientAppointmentDetailScreen(appointmentId: appointmentId);
      //   },
      // ),
      // GoRoute(
      //   path: AppConstants.clientDocumentDetailRoute,
      //   builder: (context, state) {
      //     final documentId = state.pathParameters['id']!;
      //     return ClientDocumentDetailScreen(documentId: documentId);
      //   },
      // ),
      // GoRoute(
      //   path: AppConstants.clientPaymentDetailRoute,
      //   builder: (context, state) {
      //     final paymentId = state.pathParameters['id']!;
      //     return ClientPaymentDetailScreen(paymentId: paymentId);
      //   },
      // ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Page Not Found',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'The requested page could not be found.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go(AppConstants.splashRoute),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
  );
}
