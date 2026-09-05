import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LaxmiTradingApp());
}

class LaxmiTradingApp extends StatelessWidget {
  const LaxmiTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laxmi Trading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const LaxmiTradingHomeScreen(),
    );
  }
}

class LaxmiTradingHomeScreen extends StatefulWidget {
  const LaxmiTradingHomeScreen({super.key});

  @override
  State<LaxmiTradingHomeScreen> createState() => _LaxmiTradingHomeScreenState();
}

class _LaxmiTradingHomeScreenState extends State<LaxmiTradingHomeScreen> {
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  void initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Scaffold(
        body: Center(
          child: Text(
            'Firebase Initialization Failed',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

    if (!_initialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laxmi Trading'),
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Welcome Back, Trader!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Firebase is successfully connected and running.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.greenAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
