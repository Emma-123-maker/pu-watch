import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/pu_search_screen.dart';
import 'screens/check_in_screen.dart';
import 'screens/help_support_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 🔒 Offline init
  await Hive.initFlutter();
  await Hive.openBox('checkins_queue');
  runApp(PUWatchApp());
}

class PUWatchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PU-Watch',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int idx = 0;
  final pages = [PUSearchScreen(), CheckInScreen(), HelpSupportScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        selectedItemColor: Colors.green[800],
        onTap: (i) => setState(() => idx = i),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Find PU"),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "Check-In"),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: "Help"),
        ],
      ),
    );
  }
}
