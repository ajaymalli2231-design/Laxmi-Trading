import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        primarySwatch: Colors.blue,
      ),
      home: const StockHomeScreen(),
    );
  }
}

class StockHomeScreen extends StatefulWidget {
  const StockHomeScreen({super.key});

  @override
  State<StockHomeScreen> createState() => _StockHomeScreenState();
}

class _StockHomeScreenState extends State<StockHomeScreen> {
  final List<Map<String, dynamic>> stocks = [
    {'name': 'RELIANCE', 'price': '2,945.50', 'change': '+1.25%', 'isUp': true},
    {'name': 'TCS', 'price': '4,120.00', 'change': '-0.45%', 'isUp': false},
    {'name': 'INFY', 'price': '1,650.25', 'change': '+2.10%', 'isUp': true},
    {'name': 'HDFC BANK', 'price': '1,480.90', 'change': '+0.80%', 'isUp': true},
    {'name': 'NIFTY 50', 'price': '22,420.10', 'change': '+0.65%', 'isUp': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laxmi Trading Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.amber),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Portfolio Value', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      SizedBox(height: 8),
                      Text('₹ 4,85,250.00', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Icon(Icons.trending_up, color: Colors.greenAccent, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Market Watchlist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: stocks.length,
                itemBuilder: (context, index) {
                  final stock = stocks[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(stock['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            const SizedBox(height: 4),
                            const Text('NSE', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹ ${stock['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                              stock['change'],
                              style: TextStyle(
                                color: stock['isUp'] ? Colors.greenAccent : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
