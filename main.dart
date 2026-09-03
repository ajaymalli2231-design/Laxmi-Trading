import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

// -----------------------------------------------------------------------------
// USER DATA MODEL
// -----------------------------------------------------------------------------
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

// Global User Database (Admin Credentials Set)
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

// -----------------------------------------------------------------------------
// ADVANCED STOCK MODEL (WITH TECHNICAL INDICATORS & MARKET DEPTH)
// -----------------------------------------------------------------------------
class StockItem {
  final String symbol;
  final String segment;
  double price;
  double change;
  final int lotSize;
  double rsi;
  String signal;
  List<double> history;

  StockItem({
    required this.symbol,
    required this.segment,
    required this.price,
    required this.change,
    required this.lotSize,
    this.rsi = 55.0,
    this.signal = 'NEUTRAL',
    List<double>? history,
  }) : history = history ?? [price - 2, price - 1, price, price + 1, price];
}

// -----------------------------------------------------------------------------
// 1. AUTHENTICATION SCREEN (MOBILE + PASSWORD LOGIN)
// -----------------------------------------------------------------------------
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
        const SnackBar(content: Text('Please enter Mobile Number and Password')),
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
        const SnackBar(content: Text('Invalid Credentials! Check Mobile Number or Password.')),
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
            const Text('Institutional Order Execution Platform', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _isObscured,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _handleLogin,
              child: const Text('LOGIN TO TERMINAL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. MAIN DASHBOARD
// -----------------------------------------------------------------------------
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.user.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                if (widget.user.isAdmin) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                    child: const Text('ADMIN', style: TextStyle(fontSize: 9, color: Colors.black, fontWeight: FontWeight.bold)),
                  )
                ]
              ],
            ),
            Text(
              widget.user.isAdmin
                  ? 'System Administration Active'
                  : 'Fund: ₹${widget.user.balance.toStringAsFixed(2)} | Limit: ₹${widget.user.limit.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 11, color: Colors.greenAccent),
            ),
          ],
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
            const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin Panel'),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. REAL MARKET WATCH & AI ANALYTICS
// -----------------------------------------------------------------------------
class MarketWatchScreen extends StatefulWidget {
  final UserAccount user;
  const MarketWatchScreen({super.key, required this.user});

  @override
  State<MarketWatchScreen> createState() => _MarketWatchScreenState();
}

class _MarketWatchScreenState extends State<MarketWatchScreen> {
  Timer? _fetchTimer;
  List<StockItem> stocks = [
    StockItem(symbol: "NIFTY 50", segment: "NSE INDEX", price: 22450.0, change: 12.0, lotSize: 50, rsi: 62.4, signal: 'BULLISH'),
    StockItem(symbol: "BANKNIFTY", segment: "NSE INDEX", price: 47800.0, change: -30.0, lotSize: 15, rsi: 41.2, signal: 'BEARISH'),
    StockItem(symbol: "SENSEX", segment: "BSE INDEX", price: 73800.0, change: 45.0, lotSize: 10, rsi: 58.0, signal: 'NEUTRAL'),
    StockItem(symbol: "CRUDEOIL FUT", segment: "MCX FUT", price: 6450.0, change: 85.0, lotSize: 100, rsi: 68.5, signal: 'STRONG BUY'),
    StockItem(symbol: "GOLD FUT", segment: "MCX FUT", price: 72150.0, change: -120.0, lotSize: 1, rsi: 38.1, signal: 'OVERSOLD'),
    StockItem(symbol: "RELIANCE EQ", segment: "NSE STK", price: 2980.0, change: 5.5, lotSize: 1, rsi: 54.2, signal: 'NEUTRAL'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          for (var s in stocks) {
            double delta = (DateTime.now().millisecond % 10 - 5) / 2;
            s.price += delta;
            s.change += delta;
            s.history.add(s.price);
            if (s.history.length > 10) s.history.removeAt(0);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
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
          margin: const EdgeInsets.horizontal(12, vertical: 6),
          child: ListTile(
            title: Row(
              children: [
                Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                  child: Text(stock.signal, style: TextStyle(fontSize: 8, color: stock.signal.contains('BUY') || stock.signal.contains('BULL') ? Colors.green : Colors.redAccent)),
                )
              ],
            ),
            subtitle: Text("${stock.segment} | RSI: ${stock.rsi.toStringAsFixed(1)}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("₹${stock.price.toStringAsFixed(2)}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isPositive ? Colors.green : Colors.red)),
                Text("${isPositive ? '+' : ''}${stock.change.toStringAsFixed(2)}", style: TextStyle(fontSize: 11, color: isPositive ? Colors.green : Colors.red)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderTerminalScreen(user: widget.user, stock: stock)),
              );
            },
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// 4. ORDER TERMINAL WITH STOP-LOSS & TAKE-PROFIT
// -----------------------------------------------------------------------------
class OrderTerminalScreen extends StatefulWidget {
  final UserAccount user;
  final StockItem stock;

  const OrderTerminalScreen({super.key, required this.user, required this.stock});

  @override
  State<OrderTerminalScreen> createState() => _OrderTerminalScreenState();
}

class _OrderTerminalScreenState extends State<OrderTerminalScreen> {
  int _lots = 1;
  double _stopLoss = 0.0;
  double _takeProfit = 0.0;

  @override
  void initState() {
    super.initState();
    _stopLoss = widget.stock.price * 0.98;
    _takeProfit = widget.stock.price * 1.05;
  }

  void _executeTrade() {
    double totalCost = _lots * widget.stock.lotSize * widget.stock.price;
    if (totalCost > widget.user.limit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order Rejected! Required capital exceeds Admin Trading Limit.')),
      );
      return;
    }

    setState(() {
      widget.user.limit -= totalCost;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order Placed Successfully for ${widget.stock.symbol}!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double totalMargin = _lots * widget.stock.lotSize * widget.stock.price;

    return Scaffold(
      appBar: AppBar(title: Text("Trade ${widget.stock.symbol}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.stock.symbol, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text("₹${widget.stock.price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Lots"),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle), onPressed: () => setState(() { if (_lots > 1) _lots--; })),
                    Text("$_lots", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.add_circle), onPressed: () => setState(() => _lots++)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Text("Stop Loss (SL): ₹${_stopLoss.toStringAsFixed(2)}", style: const TextStyle(color: Colors.redAccent)),
            Text("Take Profit (TP): ₹${_takeProfit.toStringAsFixed(2)}", style: const TextStyle(color: Colors.greenAccent)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Required Margin:"),
                  Text("₹${totalMargin.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _executeTrade,
                child: const Text("EXECUTE ORDER", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. PORTFOLIO & POSITIONS
// -----------------------------------------------------------------------------
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
                    const Text("Available Funds"),
                    Text("₹${user.balance.toStringAsFixed(2)}", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Trading Limit"),
                    Text("₹${user.limit.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

// -----------------------------------------------------------------------------
// 6. ADMIN PANEL (EXCLUSIVE FOR AJAY)
// -----------------------------------------------------------------------------
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.gree
