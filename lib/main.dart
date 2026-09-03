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
// MODELS & GLOBAL DATA
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
  UserAccount(name: 'Ajay (Admin)', phone: '9999999999', password: 'Ajay999', balance: 10024000.0, limit: 50000000.0, isAdmin: true),
  UserAccount(name: 'Rahul Sharma', phone: '9876543210', password: 'user123', balance: 50000.0, limit: 200000.0, isAdmin: false),
];

class StockItem {
  final String symbol;
  final String segment; // INDEX, F&O, STK
  double price;
  double change;
  double high;
  double low;
  final int lotSize;
  List<double> priceHistory;

  StockItem({
    required this.symbol,
    required this.segment,
    required this.price,
    required this.change,
    required this.high,
    required this.low,
    required this.lotSize,
    required this.priceHistory,
  });
}

class PositionItem {
  final String symbol;
  final int lots;
  final int lotSize;
  final double buyPrice;
  final String type; // BUY or SELL

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
  // INDICES
  StockItem(symbol: "NIFTY 50", segment: "NSE INDEX", price: 22504.02, change: 130.82, high: 22550.0, low: 22350.0, lotSize: 50, priceHistory: [22400, 22420, 22410, 22450, 22480, 22504]),
  StockItem(symbol: "BANKNIFTY", segment: "NSE INDEX", price: 47933.69, change: -131.61, high: 48100.0, low: 47850.0, lotSize: 15, priceHistory: [48050, 48000, 47980, 47920, 47950, 47933]),
  
  // OPTIONS (CALL / PUT)
  StockItem(symbol: "NIFTY 22500 CE", segment: "OPTION CALL", price: 145.50, change: 22.30, high: 160.0, low: 95.0, lotSize: 50, priceHistory: [100, 115, 110, 130, 140, 145.5]),
  StockItem(symbol: "NIFTY 22500 PE", segment: "OPTION PUT", price: 82.20, change: -18.40, high: 120.0, low: 75.0, lotSize: 50, priceHistory: [110, 105, 98, 90, 85, 82.2]),
  StockItem(symbol: "BANKNIFTY 48000 CE", segment: "OPTION CALL", price: 280.10, change: -45.00, high: 360.0, low: 250.0, lotSize: 15, priceHistory: [330, 320, 300, 290, 285, 280]),
  StockItem(symbol: "BANKNIFTY 48000 PE", segment: "OPTION PUT", price: 310.40, change: 38.60, high: 340.0, low: 260.0, lotSize: 15, priceHistory: [270, 280, 295, 305, 300, 310]),
  
  // EQUITIES & FUTURES
  StockItem(symbol: "RELIANCE EQ", segment: "NSE STK", price: 2999.59, change: 32.69, high: 3009.6, low: 2960.0, lotSize: 1, priceHistory: [2960, 2975, 2970, 2985, 2990, 2999]),
  StockItem(symbol: "TATA MOTORS", segment: "NSE STK", price: 985.40, change: 14.20, high: 992.0, low: 970.0, lotSize: 1, priceHistory: [972, 975, 978, 982, 980, 985]),
  StockItem(symbol: "HDFC BANK", segment: "NSE STK", price: 1442.10, change: -8.50, high: 1460.0, low: 1438.0, lotSize: 1, priceHistory: [1452, 1450, 1448, 1440, 1445, 1442]),
  StockItem(symbol: "INFOSYS EQ", segment: "NSE STK", price: 1520.00, change: 5.80, high: 1532.0, low: 1510.0, lotSize: 1, priceHistory: [1512, 1515, 1518, 1522, 1519, 1520]),
  StockItem(symbol: "CRUDEOIL FUT", segment: "MCX FUT", price: 6519.72, change: 83.72, high: 6540.0, low: 6410.0, lotSize: 100, priceHistory: [6430, 6450, 6480, 6500, 6510, 6519]),
  StockItem(symbol: "GOLD FUT", segment: "MCX FUT", price: 72363.16, change: -196.84, high: 72600.0, low: 72200.0, lotSize: 1, priceHistory: [72550, 72500, 72450, 72400, 72380, 72363]),
];

// -----------------------------------------------------------------------------
// AUTHENTICATION
// -----------------------------------------------------------------------------
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController(text: "9999999999");
  final _passwordController = TextEditingController(text: "Ajay999");

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
            const Icon(Icons.show_chart_rounded, size: 80, color: Color(0xFF00C853)),
            const SizedBox(height: 10),
            const Text('LAXMI TERMINAL', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const Text('Pro Options & Equity Trader', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 40),
            TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), padding: const EdgeInsets.symmetric(vertical: 16)),
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
    // Simulation of live price ticking
    _marketTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        setState(() {
          for (var s in globalStocks) {
            double tick = (_rnd.nextDouble() * 3 - 1.4);
            s.price += tick;
            s.change += tick;
            if (s.price > s.high) s.high = s.price;
            if (s.price < s.low) s.low = s.price;

            s.priceHistory.add(s.price);
            if (s.priceHistory.length > 20) {
              s.priceHistory.removeAt(0);
            }
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
            Text(widget.user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Balance: ₹${widget.user.balance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.greenAccent)),
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
// WATCHLIST WITH SEARCH & CATEGORIES
// -----------------------------------------------------------------------------
class MarketWatchScreen extends StatefulWidget {
  final UserAccount user;
  const MarketWatchScreen({super.key, required this.user});

  @override
  State<MarketWatchScreen> createState() => _MarketWatchScreenState();
}

class _MarketWatchScreenState extends State<MarketWatchScreen> {
  String _searchQuery = "";
  String _selectedCategory = "ALL";

  @override
  Widget build(BuildContext context) {
    List<StockItem> filteredStocks = globalStocks.where((s) {
      bool matchesSearch = s.symbol.toLowerCase().contains(_searchQuery.toLowerCase());
      if (_selectedCategory == "OPTIONS") {
        return matchesSearch && s.segment.contains("OPTION");
      } else if (_selectedCategory == "STOCKS") {
        return matchesSearch && s.segment.contains("STK");
      } else if (_selectedCategory == "INDICES") {
        return matchesSearch && s.segment.contains("INDEX");
      }
      return matchesSearch;
    }).toList();

    return Column(
      children: [
        // Search Box
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: "Search Stock, Call / Put (e.g. NIFTY CE)...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF151D2A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: ["ALL", "INDICES", "OPTIONS", "STOCKS"].map((cat) {
              bool isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: const Color(0xFF00C853),
                  onSelected: (bool selected) {
                    setState(() => _selectedCategory = cat);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: filteredStocks.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white10),
            itemBuilder: (context, index) {
              final stock = filteredStocks[index];
              final isPos = stock.change >= 0;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DetailedStockScreen(user: widget.user, stock: stock)));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// DETAILED STOCK SCREEN WITH CANDLESTICK CHART
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Rejected! Insufficient Wallet Balance.')));
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
                    Text("₹${widget.stock.price.toStringAsFixed(2)}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isPos ? const Color(0xFF00C853) : Colors.redAccent)),
                    Text("${isPos ? '+' : ''}${widget.stock.change.toStringAsFixed(2)}", style: TextStyle(color: isPos ? const Color(0xFF00C853) : Colors.redAccent, fontSize: 14)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6)),
                  child: Text("Lot Size: ${widget.stock.lotSize}", style: const TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 20),
            
            // CANDLESTICK / LINE CHART
            const Text("LIVE MARKET CHART", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              height: 180,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF151D2A), borderRadius: BorderRadius.circular(8)),
              child: CustomPaint(
                painter: CandlestickPainter(priceHistory: widget.stock.priceHistory),
              ),
            ),
            
            const SizedBox(height: 20),
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
            Text("Required Margin: ₹${(_lots * widget.stock.lotSize * widget.stock.price * 0.1).toStringAsFixed(2)}", style: const TextStyle(color: Colors.amber, fontSize: 13)),
            const Spacer(),
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
// CANDLESTICK PAINTER (CHART DRAWING)
// -----------------------------------------------------------------------------
class CandlestickPainter extends CustomPainter {
  final List<double> priceHistory;
  CandlestickPainter({required this.priceHistory});

  @override
  void paint(Canvas canvas, Size size) {
    if (priceHistory.length < 2) return;

    double maxP = priceHistory.reduce(max);
    double minP = priceHistory.reduce(min);
    if (maxP == minP) maxP += 1.0;

    double candleWidth = size.width / priceHistory.length;

    for (int i = 0; i < priceHistory.length; i++) {
      double current = priceHistory[i];
      double previous = i > 0 ? priceHistory[i - 1] : current;
      bool isGreen = current >= previous;

      Paint paint = Paint()
        ..color = isGreen ? const Color(0xFF00C853) : Colors.redAccent
        ..strokeWidth = 2.0
        ..style = PaintingStyle.fill;

      double x = i * candleWidth + (candleWidth / 2);
      double highY = size.height - ((current - minP) / (maxP - minP) * size.height * 0.8) - 10;
      double lowY = size.height - ((previous - minP) / (maxP - minP) * size.height * 0.8) - 10;

      // Draw Candlestick Body
      canvas.drawRect(
        Rect.fromLTRB(x - (candleWidth * 0.3), highY, x + (candleWidth * 0.3), lowY),
        paint,
      );

      // Draw Wick Line
      canvas.drawLine(Offset(x, highY - 5), Offset(x, lowY + 5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// -----------------------------------------------------------------------------
// POSITIONS & PNL
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
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: totalPnL >= 0 ? Colors.greenAccent : Colors.redAccent),
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
                          subtitle: Text("Qty: ${pos.lots * pos.lotSize} | Buy Avg: ₹${pos.buyPrice.toStringAsFixed(2)}"),
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
// WALLET SCREEN
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
        content: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Enter Amount (₹)", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              double amt = double.tryParse(_amountController.text) ?? 0.0;
              if (amt <= 0) return;
              setState(() {
                if (type == "DEPOSIT") {
                  widget.user.balance += amt;
                } else if (amt <= widget.user.balance) {
                  widget.user.balance -= amt;
                }
              });
              Navigator.pop(context);
            },
            child: Text(type),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFF151D2A), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Wallet Balance", style: TextStyle(color: Colors.grey)),
                Text("₹${widget.user.balance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () => _showTransactionDialog("DEPOSIT"),
                  child: const Text("ADD DEPOSIT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () => _showTransactionDialog("WITHDRAW"),
                  child: const Text("WITHDRAW", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ADMIN PANEL
// -----------------------------------------------------------------------------
class AdminPanelScreen extends StatefulWidget {
  final UserAccount adminUser;
  const AdminPanelScreen({super.key, required this.adminUser});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  Widget build(BuildContext context) {
    final customers = globalUsers.where((u) => !u.isAdmin).toList();
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final c = customers[index];
        return Card(
          child: ListTile(
            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Mobile: ${c.phone}\nBalance: ₹${c.balance.toStringAsFixed(2)}"),
          ),
        );
      },
    );
  }
}
