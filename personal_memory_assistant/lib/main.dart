import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:personal_memory_assistant/screens/signup_page.dart';
import 'package:personal_memory_assistant/screens/dashboard_page.dart';
import 'package:personal_memory_assistant/services/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_memory_assistant/screens/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBm_RApMOLsAQABXjX_enFuHPvighvDrVw",
        authDomain: "my-firebase-project-c2bbe.firebaseapp.com",
        projectId: "my-firebase-project-c2bbe",
        storageBucket: "my-firebase-project-c2bbe.appspot.com",
        messagingSenderId: "644968277000",
        appId: "1:644968277000:web:3a93f2de1752af6f1a9dbd",
      ),
    );
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  // Initialize Timezone
  tz.initializeTimeZones();

  // Initialize NotificationService
  try {
    await NotificationService().requestPermissions();
  } catch (e) {
    print("NotificationService initialization failed: $e");
  }

  // Initialize FlutterLocalNotificationsPlugin for task_input_page
  try {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidInitSettings, iOS: iosInitSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  } catch (e) {
    print("FlutterLocalNotificationsPlugin initialization failed: $e");
  }

  
  try {
    await Hive.initFlutter();
    await Hive.openBox('app_data');
  } catch (e) {
    print("Hive initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Memory Assistant',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return const DashboardPage();
        }
        return const SignupPage();
      },
    );
  }
}