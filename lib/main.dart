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
        primarySwatch: Colors.blue,
      ),
      home: const TradingHome(),
    );
  }
}

class TradingHome extends StatefulWidget {
  const TradingHome({super.key});

  @override
  State<TradingHome> createState() => _TradingHomeState();
}

class _TradingHomeState extends State<TradingHome> {
  int _currentIndex = 0;
  String btcPrice = "Loading...";
  String btcChange = "-";

  @override
  void initState() {
    super.initState();
    fetchMarketData();
  }

  Future<void> fetchMarketData() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.coincap.io/v2/assets/bitcoin'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final price = double.parse(data['data']['priceUsd']).toStringAsFixed(2);
        final change = double.parse(data['data']['changePercent24Hr']).toStringAsFixed(2);
        setState(() {
          btcPrice = price;
          btcChange = "$change%";
        });
      }
    } catch (e) {
      setState(() {
        btcPrice = "Error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INTRADAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('LIVE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const Icon(Icons.search),
          const SizedBox(width: 15),
          const Icon(Icons.notifications_none),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          // कैटेगरी टैब्स (MCX, NSE, OPT, CRYPTO, FOREX)
          Container(
            color: const Color(0xFF1E293B),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: SpaceAroundTabs(),
              children: const [
                Text('MCX', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                Text('NSE', style: TextStyle(color: Colors.grey)),
                Text('OPT', style: TextStyle(color: Colors.grey)),
                Text('CRYPTO', style: TextStyle(color: Colors.grey)),
                Text('FOREX', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          // हेडर (SYMBOL, BUY, SELL)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF0F172A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('SYMBOL', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Row(
                  children: [
                    Text('BUY', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    SizedBox(width: 45),
                    Text('SELL', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          
          // स्टॉक लिस्ट व्यू
          Expanded(
            child: ListView(
              children: [
                _buildStockItem(
                  symbol: 'BITCOIN / USD',
                  subtext: 'Live Crypto Feed',
                  change: btcChange,
                  ltp: btcPrice,
                  buyPrice: btcPrice,
                  sellPrice: (double.tryParse(btcPrice) != null) ? (double.parse(btcPrice) + 5).toStringAsFixed(2) : '0.00',
                  context: context,
                ),
                _buildStockItem(
                  symbol: 'SILVERMIC • 1',
                  subtext: '28Jun2024',
                  change: 'CH: -204',
                  ltp: '88715.0',
                  buyPrice: '88707',
                  sellPrice: '88720',
                  context: context,
                ),
                _buildStockItem(
                  symbol: 'CRUDEOIL',
                  subtext: '19Jul2024',
                  change: 'CH: 12',
                  ltp: '6714.0',
                  buyPrice: '6712',
                  sellPrice: '6714',
                  context: context,
                ),
              ],
            ),
          ),
          
          // डेमो अकाउंट बैनर
          Container(
            width: double.infinity,
            color: Colors.red[900],
            padding: const EdgeInsets.all(6),
            child: const Text(
              'This is Demo Account',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Watchlist'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Trades'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Portfolio'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }

  Widget _buildStockItem({
    required String symbol,
    required String subtext,
    required String change,
    required String ltp,
    required String buyPrice,
    required String sellPrice,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtext, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(70, 36),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      _showOrderDialog(context, symbol, buyPrice, 'BUY');
                    },
                    child: Text(buyPrice, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(70, 36),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      _showOrderDialog(context, symbol, sellPrice, 'SELL');
                    },
                    child: Text(sellPrice, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(change, style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
              const SizedBox(width: 15),
              Text("LTP: $ltp", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrderDialog(BuildContext context, String symbol, String price, String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text('$type Order Triggered'),
          ],
        ),
        content: Text('$type Order placed in $symbol for 1 Lot at $price'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  SpaceAroundTabs() => MainAxisAlignment.spaceAround;
}
