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
  String stockPrice = "Connecting to Live Market...";

  @override
  void initState() {
    super.initState();
    fetchStockPrice();
  }

  Future<void> fetchStockPrice() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.coincap.io/v2/assets/bitcoin'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final price = data['data']['priceUsd'];
        // कीमत को सुंदर फॉर्मेट में दिखाना
        final doubleParsed = double.parse(price).toStringAsFixed(2);
        setState(() {
          stockPrice = "BTC Live: \$$doubleParsed";
        });
      } else {
        setState(() {
          stockPrice = "Market Server Busy (${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        stockPrice = "Connection Error. Check Wi-Fi.";
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'NSE / Crypto Live Feed',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 15),
              Text(
                stockPrice,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: fetchStockPrice,
                child: const Text('Refresh Price', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
