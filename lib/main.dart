import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lawyer_app/screens/client_screen.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/case_details_screen.dart';
import 'screens/client_details_screen.dart';
import 'screens/document_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/cases_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/case_provider.dart';
import 'providers/client_provider.dart';
import 'providers/document_provider.dart';
import 'providers/event_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the proper options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Your app configuration
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CaseProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: MaterialApp(
        title: 'Lawyer Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color(0xFF1A237E),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Color(0xFF1A237E),
            secondary: Color(0xFF303F9F),
            surface: Colors.white,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1A237E),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          textTheme: TextTheme(
            headlineMedium: TextStyle(
              color: Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
            ),
            titleLarge: TextStyle(
              color: Color(0xFF1A237E),
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: TextStyle(color: Colors.black87),
            bodyMedium: TextStyle(color: Colors.black54),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1A237E),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF1A237E), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => SplashScreen(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/cases': (context) => CasesScreen(),
          '/case-details': (context) => CaseDetailsScreen(),
          '/clients': (context) => ClientsScreen(),
          '/client-details': (context) => ClientDetailsScreen(),
          '/documents': (context) => DocumentScreen(),
          '/calendar': (context) => CalendarScreen(),
        },
      ),
    );
  }
}
