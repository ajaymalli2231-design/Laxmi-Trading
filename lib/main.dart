import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const LaxmiTradingApp());
}

class LaxmiTradingApp extends StatelessWidget {
  const LaxmiTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laxmi Trading Terminal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0E14),
        cardColor: const Color(0xFF151D2A),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF151D2A), elevation: 0),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00C853),
          secondary: Color(0xFF2962FF),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// MODELS
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

List<UserAccount> globalUsers = [
  UserAccount(name: 'Ajay (Admin)', phone: '9999999999', password: 'Ajay999', balance: 10000000.0, limit: 10000000.0, isAdmin: true),
  UserAccount(name: 'Rahul Sharma', phone: '9876543210', password: 'user123', balance: 50000.0, limit: 200000.0, isAdmin: false),
];

class StockItem {
  final String symbol;
  final String segment;
  double price;
  double change;
  double percentChange;
  double high;
  double low;
  final int lotSize;

  StockItem({
    required this.symbol,
    required this.segment,
    required this.price,
    required this.change,
    required this.percentChange,
    required this.high,
    required this.low,
    required this.lotSize,
  });
}

class PositionItem {
  final String symbol;
  final int lots;
  final int lotSize;
  final double buyPrice;
  final String type;

  PositionItem({
    required this.symbol,
    required this.lots,
    required this.lotSize,
    required this.buyPrice,
    required this.type,
  });
}

List<PositionItem> globalPositions = [];
List<StockItem> globalStocks = [
  StockItem(symbol: "NIFTY 50", segment: "NSE INDEX", price: 22485.50, change: 112.30, percentChange: 0.50, high: 22510.0, low: 22350.0, lotSize: 50),
  StockItem(symbol: "BANKNIFTY", segment: "NSE INDEX", price: 47920.10, change: -145.20, percentChange: -0.30, high: 48100.0, low: 47850.0, lotSize: 15),
  StockItem(symbol: "CRUDEOIL FUT", segment: "MCX FUT", price: 6520.00, change: 84.00, percentChange: 1.30, high: 6540.0, low: 6410.0, lotSize: 100),
  StockItem(symbol: "GOLD FUT", segment: "MCX FUT", price: 72350.00, change: -210.00, percentChange: -0.29, high: 72600.0, low: 72200.0, lotSize: 1),
  StockItem(symbol: "RELIANCE EQ", segment: "NSE STK", price: 2985.40, change: 18.50, percentChange: 0.62, high: 2995.0, low: 2960.0, lotSize: 1),
];

// -----------------------------------------------------------------------------
// AUTH SCREEN
// -----------------------------------------------------------------------------
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() {
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();

    try {
      UserAccount user = globalUsers.firstWhere((u) => u.phone == phone && u.password == password);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainDashboard(user: user)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('गलत मोबाइल नंबर या पासवर्ड!')));
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
            const Icon(Icons.show_chart_rounded, size: 72, color: Color(0xFF00C853)),
            const SizedBox(height: 10),
            const Text('LAXMI TRADING', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const Text('Real-Time Market Terminal', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 30),
            TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _handleLogin,
              child: const Text('LOGIN TO APP', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MAIN DASHBOARD
// -----------------------------------------------------------------------------
class MainDashboard extends StatefulWidget {
  final UserAccount user;
  const MainDashboard({super.key, required this.user});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;
  Timer? _marketTimer;
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _marketTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        setState(() {
          for (var s in globalStocks) {
            double tick = (_rnd.nextDouble() * 4 - 2);
            s.price += tick;
            s.change += tick;
            if (s.price > s.high) s.high = s.price;
            if (s.price < s.low) s.low = s.price;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _marketTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      MarketWatchScreen(user: widget.user),
      PortfolioScreen(user: widget.user),
      WalletScreen(user: widget.user),
    ];

    if (widget.user.isAdmin) {
      pages.add(AdminPanelScreen(adminUser: widget.user));
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.user.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text('Balance: ₹${widget.user.balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Colors.greenAccent)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthScreen()))),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF00C853),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF151D2A),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.candlestick_chart), label: 'Watchlist'),
          const BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Positions'),
          const BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          if (widget.user.isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WATCHLIST
// -----------------------------------------------------------------------------
class MarketWatchScreen extends StatelessWidget {
  final UserAccount user;
  const MarketWatchScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: globalStocks.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white10),
      itemBuilder: (context, index) {
        final stock = globalStocks[index];
        final isPos = stock.change >= 0;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text("${stock.segment} | H: ${stock.high.toStringAsFixed(1)} L: ${stock.low.toStringAsFixed(1)}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("₹${stock.price.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isPos ? const Color(0xFF00C853) : Colors.redAccent)),
              Text("${isPos ? '+' : ''}${stock.change.toStringAsFixed(2)}", style: TextStyle(fontSize: 11, color: isPos ? const Color(0xFF00C853) : Colors.redAccent)),
            ],
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => DetailedStockScreen(user: user, stock: stock)));
          },
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// STOCK BUY / SELL TERMINAL
// -----------------------------------------------------------------------------
class DetailedStockScreen extends StatefulWidget {
  final UserAccount user;
  final StockItem stock;

  const DetailedStockScreen({super.key, required this.user, required this.stock});

  @override
  State<DetailedStockScreen> createState() => _DetailedStockScreenState();
}

class _DetailedStockScreenState extends State<DetailedStockScreen> {
  int _lots = 1;

  void _placeTrade(String type) {
    double totalMargin = _lots * widget.stock.lotSize * widget.stock.price * 0.1;
    if (totalMargin > widget.user.balance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Rejected! Insufficient Balance in Wallet.')));
      return;
    }

    globalPositions.add(PositionItem(
      symbol: widget.stock.symbol,
      lots: _lots,
      lotSize: widget.stock.lotSize,
      buyPrice: widget.stock.price,
      type: type,
    ));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: type == 'BUY' ? Colors.green : Colors.red, content: Text('$type Order Executed for ${widget.stock.symbol}!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isPos = widget.stock.change >= 0;

    return Scaffold(
      appBar: AppBar(title: Text(widget.stock.symbol)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("₹${widget.stock.price.toStringAsFixed(2)}", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isPos ? const Color(0xFF00C853) : Colors.redAccent)),
                    Text("${isPos ? '+' : ''}${widget.stock.change.toStringAsFixed(2)}", style: TextStyle(color: isPos ? const Color(0xFF00C853) : Colors.redAccent)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                  child: Text("Lot Size: ${widget.stock.lotSize}", style: const TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 20),
            const Text("LIVE MARKET DEPTH", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Table(
              children: [
                const TableRow(children: [
                  Text("BID QTY", style: TextStyle(color: Colors.green, fontSize: 11)),
                  Text("BID PRICE", style: TextStyle(color: Colors.green, fontSize: 11)),
                  Text("ASK PRICE", style: TextStyle(color: Colors.red, fontSize: 11)),
                  Text("ASK QTY", style: TextStyle(color: Colors.red, fontSize: 11)),
                ]),
                TableRow(children: [
                  const Text("150"),
                  Text((widget.stock.price - 0.20).toStringAsFixed(2)),
                  Text((widget.stock.price + 0.20).toStringAsFixed(2)),
                  const Text("200"),
                ]),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Select Lots:"),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() { if (_lots > 1) _lots--; })),
                    Text("$_lots", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => _lots++)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 10),
            Text("Required Margin: ₹${(_lots * widget.stock.lotSize * widget.stock.price * 0.1).toStringAsFixed(2)}", style: const TextStyle(color: Colors.amber)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () => _placeTrade('BUY'),
                    child: const Text('BUY', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () => _placeTrade('SELL'),
                    child: const Text('SELL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// POSITIONS & LIVE REAL-TIME P&L
// -----------------------------------------------------------------------------
class PortfolioScreen extends StatelessWidget {
  final UserAccount user;
  const PortfolioScreen({super.key, required this.user});

  double _calculatePnL(PositionItem pos) {
    try {
      final currentStock = globalStocks.firstWhere((s) => s.symbol == pos.symbol);
      double diff = currentStock.price - pos.buyPrice;
      if (pos.type == 'SELL') diff = -diff;
      return diff * (pos.lots * pos.lotSize);
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPnL = globalPositions.fold(0.0, (sum, pos) => sum + _calculatePnL(pos));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF151D2A), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Realtime P&L', style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text(
                  '₹${totalPnL.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: totalPnL >= 0 ? Colors.greenAccent : Colors.redAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text("OPEN POSITIONS", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 10),
          Expanded(
            child: globalPositions.isEmpty
                ? const Center(child: Text("No Open Positions", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: globalPositions.length,
                    itemBuilder: (context, index) {
                      final pos = globalPositions[index];
                      double pnl = _calculatePnL(pos);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text("${pos.symbol} [${pos.type}]", style: TextStyle(fontWeight: FontWeight.bold, color: pos.type == 'BUY' ? Colors.green : Colors.redAccent)),
                          subtitle: Text("Qty: ${pos.lots * pos.lotSize} | Avg: ₹${pos.buyPrice.toStringAsFixed(2)}"),
                          trailing: Text(
                            "₹${pnl.toStringAsFixed(2)}",
                            style: TextStyle(fontWeight: FontWeight.bold, color: pnl >= 0 ? Colors.greenAccent : Colors.redAccent),
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WALLET (DEPOSIT & WITHDRAWAL SCREEN)
// -----------------------------------------------------------------------------
class WalletScreen extends StatefulWidget {
  final UserAccount user;
  const WalletScreen({super.key, required this.user});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _amountController = TextEditingController();

  void _showTransactionDialog(String type) {
    _amountController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$type Funds"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter Amount (₹)", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButt
