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

// 1. लॉगिन स्क्रीन (मोबाइल नंबर और पासवर्ड Ajay900)
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
        MaterialPageRoute(builder: (context) => MainDashboard(userPhone: phone)),
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
                const Text('Laxmi Trading Live', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
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
                    child: const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
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

// ग्लोबल फंड वेरिएबल ताकि एडमिन इसे कंट्रोल कर सके
double globalUserFunds = 50000.0;

class MainDashboard extends StatefulWidget {
  final String userPhone;
  const MainDashboard({super.key, required this.userPhone});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;
  String selectedTab = 'NSE';

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      buildWatchlistTab(),
      const Center(child: Text('Active & Closed Trades', style: TextStyle(fontSize: 18))),
      const Center(child: Text('Portfolio Holdings', style: TextStyle(fontSize: 18))),
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

  // वॉचलिस्ट और इंडिसेज/ऑप्शन चेन टैब
  Widget buildWatchlistTab() {
    return Column(
      children: [
        // फंड डिस्प्ले बार
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          color: const Color(0xFF1E293B),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('User: ${widget.userPhone}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text('Available Funds: ₹${globalUserFunds.toStringAsFixed(2)}', 
                style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
        // कैटेगरी बार
        Container(
          color: const Color(0xFF162032),
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
        content: Text('$type order placed successfully for $symbol at $price'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
        ],
      ),
    );
  }

  // अकाउंट टैब: ऐप शेयरिंग और अजय (Admin) का फंड कंट्रोल पैनल
  Widget buildAccountTab(BuildContext context) {
    final TextEditingController fundController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          const Text('Profile & Admin Controls', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Text('Logged In Phone: ${widget.userPhone}', style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 25),
          
          // अजय एडमिन फंड कण्ट्रोल सेक्शन
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blueAccent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ajay Admin Fund Control', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                const SizedBox(height: 10),
                TextField(
                  controller: fundController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter Amount to Add/Subtract',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        setState(() {
                          double val = double.tryParse(fundController.text) ?? 0;
                          globalUserFunds += val;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funds Increased Successfully')));
                      },
                      child: const Text('Add Fund'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        setState(() {
                          double val = double.tryParse(fundController.text) ?? 0;
                          globalUserFunds -= val;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funds Decreased Successfully')));
                      },
                      child: const Text('Reduce Fund'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: const Size(double.infinity, 48)),
            icon: const Icon(Icons.share, color: Colors.white),
            label: const Text('Share App with Friend', style: TextStyle(color: Colors.white, fontSize: 16)),
            onPressed: () {
              Share.share('Laxmi Trading App डाउनलोड करें! Login Password: Ajay900');
            },
          ),
        ],
      ),
    );
  }
}
