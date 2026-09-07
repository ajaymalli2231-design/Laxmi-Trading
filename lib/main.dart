import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
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
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const StockScreen(),
    );
  }
}

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String stockPrice = "Loading live price...";

  @override
  void initState() {
    super.initState();
    fetchStockPrice(); // ऐप खुलते ही डेटा मंगवाएगा
  }

  // यहाँ हम लाइव मार्केट API से डेटा फेच करते हैं
  Future<void> fetchStockPrice() async {
    try {
      // उदाहरण के लिए फ्री फाइनेंशियल API का उपयोग (आप अपनी पसंद की API लगा सकते हैं)
      final response = await http.get(Uri.parse('https://api.coindesk.com/v1/bpi/currentprice/BTC.json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          stockPrice = "Live Price: \$${data['bpi']['USD']['rate']}";
        });
      } else {
        setState(() {
          stockPrice = "Market Closed / Error";
        });
      }
    } catch (e) {
      setState(() {
        stockPrice = "Check Internet Connection";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laxmi Trading Live Market'),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Reliance / Stock Status',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              stockPrice,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchStockPrice,
              child: const Text('Refresh Price'),
            ),
          ],
        ),
      ),
    );
  }
}
