import 'dart:async';
import 'package:flutter/material.dart';

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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF22C55E),
          secondary: Color(0xFF3B82F6),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

class UserAccount {
  String name;
  String phone;
  String password;
  double balance;
  double limit;
  bool isAdmin;

  UserAccount({
    required this.name,
    required this.phone,
    required this.password,
    this.balance = 0.0,
    this.limit = 0.0,
    this.isAdmin = false,
  });
}

List<UserAccount> globalUsers = [
  UserAccount(
    name: 'Ajay (Admin)',
    phone: '9999999999',
    password: 'Ajay999',
    balance: 10000000.0,
    limit: 10000000.0,
    isAdmin: true,
  ),
  UserAccount(
    name: 'Rahul Sharma',
    phone: '9876543210',
    password: 'user123',
    balance: 50000.0,
    limit: 200000.0,
    isAdmin: false,
  ),
];

class StockItem {
  final String symbol;
  final String segment;
  double price;
  double change;
  final int lotSize;
  double rsi;
  String signal;

  StockItem({
    required this.symbol,
    required this.segment,
    required this.price,
    required this.change,
    required this.lotSize,
    this.rsi = 55.0,
    this.signal = 'NEUTRAL',
  });
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscured = true;

  void _handleLogin() {
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter Mobile Number and Password')),
      );
      return;
    }

    try {
      UserAccount user = globalUsers.firstWhere(
        (u) => u.phone == phone && u.password == password,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainDashboard(user: user)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Mobile Number or Password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.candlestick_chart, size: 72, color: Color(0xFF22C55E)),
            const SizedBox(height: 12),
            const Text(
              'LAXMI TRADING',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _isObscured,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _handleLogin,
              child: const Text('LOGIN TO TERMINAL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class MainDashboard extends StatefulWidget {
  final UserAccount user;
  const MainDashboard({super.key, required this.user});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      MarketWatchScreen(user: widget.user),
      PortfolioScreen(user: widget.user),
    ];

    if (widget.user.isAdmin) {
      pages.add(AdminPanelScreen(adminUser: widget.user));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.isAdmin
              ? 'Admin Dashboard (${widget.user.name})'
              : 'Fund: ₹${widget.user.balance.toStringAsFixed(2)} | Limit: ₹${widget.user.limit.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthScreen())),
          )
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF22C55E),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Watchlist'),
          const BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Positions'),
          if (widget.user.isAdmin)
            const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }
}

class MarketWatchScreen extends StatefulWidget {
  final UserAccount user;
  const MarketWatchScreen({super.key, required this.user});

  @override
  State<MarketWatchScreen> createState() => _MarketWatchScreenState();
}

class _MarketWatchScreenState extends State<MarketWatchScreen> {
  Timer? _timer;
  List<StockItem> stocks = [
    StockItem(symbol: "NIFTY 50", segment: "NSE INDEX", price: 22450.0, change: 12.0, lotSize: 50, rsi: 62.4, signal: 'BULLISH'),
    StockItem(symbol: "BANKNIFTY", segment: "NSE INDEX", price: 47800.0, change: -30.0, lotSize: 15, rsi: 41.2, signal: 'BEARISH'),
    StockItem(symbol: "SENSEX", segment: "BSE INDEX", price: 73800.0, change: 45.0, lotSize: 10, rsi: 58.0, signal: 'NEUTRAL'),
    StockItem(symbol: "CRUDEOIL FUT", segment: "MCX FUT", price: 6450.0, change: 85.0, lotSize: 100, rsi: 68.5, signal: 'STRONG BUY'),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          for (var s in stocks) {
            double delta = (DateTime.now().millisecond % 10 - 5) / 2;
            s.price += delta;
            s.change += delta;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        final stock = stocks[index];
        final isPositive = stock.change >= 0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${stock.segment} | RSI: ${stock.rsi.toStringAsFixed(1)}"),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("₹${stock.price.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, color: isPositive ? Colors.green : Colors.red)),
                Text("${isPositive ? '+' : ''}${stock.change.toStringAsFixed(2)}", style: TextStyle(fontSize: 11, color: isPositive ? Colors.green : Colors.red)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PortfolioScreen extends StatelessWidget {
  final UserAccount user;
  const PortfolioScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Available Balance"),
                    Text("₹${user.balance.toStringAsFixed(2)}", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Trading Limit"),
                    Text("₹${user.limit.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text("POSITIONS", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Center(child: Text("No Open Positions", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}

class AdminPanelScreen extends StatefulWidget {
  final UserAccount adminUser;
  const AdminPanelScreen({super.key, required this.adminUser});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  void _manageCustomerAccount(UserAccount customer) {
    TextEditingController fundController = TextEditingController(text: customer.balance.toString());
    TextEditingController limitController = TextEditingController(text: customer.limit.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Manage: ${customer.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: fundController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Add Balance (₹)")),
            const SizedBox(height: 10),
            TextField(controller: limitController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Set Limit (₹)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              setState(() {
                customer.balance = double.tryParse(fundController.text) ?? customer.balance;
                customer.limit = double.tryParse(limitController.text) ?? customer.limit;
              });
              Navigator.pop(context);
            },
            child: const Text("SAVE", style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = globalUsers.where((u) => !u.isAdmin).toList();

    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final c = customers[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(c.name),
            subtitle: Text("Phone: ${c.phone}\nBalance: ₹${c.balance} | Limit: ₹${c.limit}"),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () => _manageCustomerAccount(c),
              child: const Text("ADD FUND", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }
}
