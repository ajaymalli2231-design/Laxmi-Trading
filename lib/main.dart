import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

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
      home: const LoginScreen(),
    );
  }
}

// 1. लॉगिन स्क्रीन (Ajay900 पासवर्ड के साथ)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void handleLogin() {
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();

    if (phone.isNotEmpty && password == "Ajay900") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Details! Use Password: Ajay900')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_up, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 10),
                const Text('Laxmi Trading', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Friend / Mobile Number',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password (Ajay900)',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    onPressed: handleLogin,
                    child: const Text('Login to Trading', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 2. मेन डैशबोर्ड (वॉचलिस्ट, ऑप्शन चेन, ट्रेड्स, अकाउंट)
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;
  String selectedTab = 'NSE'; // डिफ़ॉल्ट NSE इंडिसेज

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      buildWatchlistTab(),
      buildTradesTab(),
      buildPortfolioTab(),
      buildAccountTab(context),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('INTRADAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
            child: const Text('LIVE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const Icon(Icons.search),
          const SizedBox(width: 15),
          const Icon(Icons.notifications_none),
          const SizedBox(width: 15),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Watchlist'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Trades'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Portfolio'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }

  // वॉचलिस्ट टैब (MCX, NSE, OPT, CRYPTO)
  Widget buildWatchlistTab() {
    return Column(
      children: [
        // कैटेगरी बार
        Container(
          color: const Color(0xFF1E293B),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['MCX', 'NSE', 'OPT', 'CRYPTO', 'FOREX'].map((tab) {
              bool isSelected = selectedTab == tab;
              return GestureDetector(
                onTap: () => setState(() => selectedTab = tab),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: isSelected ? Colors.blueAccent : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: ListView(
            children: getListItemsForCategory(),
          ),
        ),
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
    );
  }

  List<Widget> getListItemsForCategory() {
    if (selectedTab == 'NSE') {
      return [
        _stockRow('NIFTY 50', '21-Jun-2024', '+145.20', '23,465.50', '23,460', '23,470'),
        _stockRow('BANK NIFTY', '21-Jun-2024', '+320.10', '50,120.00', '50,110', '50,130'),
        _stockRow('SENSEX', '21-Jun-2024', '-85.40', '76,810.20', '76,800', '76,825'),
      ];
    } else if (selectedTab == 'OPT') {
      return [
        _stockRow('NIFTY 23500 CE', 'Call Option', '+45.50', '210.40', '209.0', '211.5'),
        _stockRow('NIFTY 23400 PE', 'Put Option', '-22.10', '98.50', '97.8', '99.2'),
        _stockRow('BANKNIFTY 50200 CE', 'Call Option', '+120.0', '450.00', '448.0', '452.0'),
      ];
    } else if (selectedTab == 'MCX') {
      return [
        _stockRow('SILVERMIC • 1', '28Jun2024', '-204', '88715.0', '88707', '88720'),
        _stockRow('CRUDEOIL', '19Jul2024', '12', '6714.0', '6712', '6714'),
      ];
    } else {
      return [
        _stockRow('BITCOIN / USD', 'Crypto Feed', '+2.4%', '67,400.0', '67,390', '67,410'),
      ];
    }
  }

  Widget _stockRow(String symbol, String sub, String change, String ltp, String buy, String sell) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(change, style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(65, 36)),
                onPressed: () => _triggerOrder(symbol, 'BUY', buy),
                child: Text(buy, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(65, 36)),
                onPressed: () => _triggerOrder(symbol, 'SELL', sell),
                child: Text(sell, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _triggerOrder(String symbol, String type, String price) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('$type Order Triggered'),
        content: Text('$type order placed for $symbol at $price'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
        ],
      ),
    );
  }

  Widget buildTradesTab() => const Center(child: Text('Active & Closed Trades', style: TextStyle(fontSize: 18)));
  Widget buildPortfolioTab() => const Center(child: Text('Portfolio Holdings', style: TextStyle(fontSize: 18)));

  // 3. अकाउंट टैब (फ्रेंड को ऐप का लिंक शेयर करने के लिए)
  Widget buildAccountTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          const Text('Logged in with Password: Ajay900', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: const Size(double.infinity, 48)),
            icon: const Icon(Icons.share, color: Colors.white),
            label: const Text('Share App with Friend', style: TextStyle(color: Colors.white, fontSize: 16)),
            onPressed: () {
              Share.share('Laxmi Trading App डाउनलोड करें और ट्रेडिंग शुरू करें! Login Password: Ajay900');
            },
          ),
        ],
      ),
    );
  }
}
