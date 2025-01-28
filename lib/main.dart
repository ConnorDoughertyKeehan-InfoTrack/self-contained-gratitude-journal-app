import 'package:flutter/material.dart';
import 'package:self_contained_gratitude/utils/notification_helper.dart';
import 'calendar_page/calendar_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures all services are initialized
  await NotificationHelper.instance.initialize(GlobalKey<NavigatorState>());
  await NotificationHelper.instance.scheduleDailyNotification();

  runApp(MyApp());
}

// main.dart
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await NotificationHelper.instance.initialize(navigatorKey);
    await NotificationHelper.instance.scheduleDailyNotification();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CalendarPage(),
    );
  }
}