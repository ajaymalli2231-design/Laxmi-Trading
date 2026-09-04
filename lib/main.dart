import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        scaffoldBackgroundColor: const Color(0xFF121418),
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00D09C),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E222D),
          elevation: 0.5,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      home: const PhoneLoginScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// DATA MODELS
// ---------------------------------------------------------------------------
class CandleData {
  final double open, high, low, close;
  CandleData({required this.open, required this.high, required this.low, required this.close});
}

class StockItem {
  final String symbol, companyName;
  double price, change;
  StockItem({required this.symbol, required this.companyName, required this.price, required this.change});
}

class ActivePosition {
  final String symbol;
  final double buyPrice;
  final int quantity;
  double currentPrice;

  ActivePosition({required this.symbol, required this.buyPrice, required this.quantity, required this.currentPrice});
  double get pnl => (currentPrice - buyPrice) * quantity;
}

class CustomerUser {
  final String id, name, phone;
  double fundLimit;
  List<ActivePosition> positions;

  CustomerUser({required this.id, required this.name, required this.phone, required this.fundLimit, required this.positions});
}

// TOP 50 STOCKS LIST
List<StockItem> top50Stocks = [
  StockItem(symbol: "RELIANCE", companyName: "Reliance Industries Ltd.", price: 2980.50, change: 1.25),
  StockItem(symbol: "TCS", companyName: "Tata Consultancy Services", price: 4210.00, change: -0.45),
  StockItem(symbol: "HDFCBANK", companyName: "HDFC Bank Ltd.", price: 1640.20, change: 0.85),
  StockItem(symbol: "ICICIBANK", companyName: "ICICI Bank Ltd.", price: 1210.75, change: 1.10),
  StockItem(symbol: "INFY", companyName: "Infosys Ltd.", price: 1820.30, change: -0.60),
  StockItem(symbol: "BHARTIARTL", companyName: "Bharti Airtel Ltd.", price: 1490.10, change: 2.15),
  StockItem(symbol: "SBIN", companyName: "State Bank of India", price: 835.60, change: 0.40),
  StockItem(symbol: "LT", companyName: "Larsen & Toubro Ltd.", price: 3620.00, change: -0.20),
  StockItem(symbol: "ITC", companyName: "ITC Ltd.", price: 495.80, change: 0.75),
  StockItem(symbol: "TATAMOTORS", companyName: "Tata Motors Ltd.", price: 1080.25, change: 3.10),
  StockItem(symbol: "ZOMATO", companyName: "Zomato Ltd.", price: 255.40, change: 2.90),
];

List<CustomerUser> registeredCustomers = [];
CustomerUser? activeCustomer;

// ---------------------------------------------------------------------------
// 1. MOBILE NUMBER LOGIN SCREEN (CUSTOMER)
// ---------------------------------------------------------------------------
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  String _error = "";

  void _sendOTP() {
    if (_phoneController.text.trim().length == 10) {
      setState(() {
        _otpSent = true;
        _error = "";
      });
    } else {
      setState(() => _error = "कृपया 10 अंकों का सही मोबाइल नंबर दर्ज करें");
    }
  }

  void _verifyOTP() {
    if (_otpController.text.trim().length >= 4) {
      String phone = _phoneController.text.trim();
      
      var existingUser = registeredCustomers.firstWhere((u) => u.phone == phone, orElse: () {
        var newUser = CustomerUser(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: "User ${phone.substring(6)}",
          phone: phone,
          fundLimit: 100000.0,
          positions: [],
        );
        registeredCustomers.add(newUser);
        return newUser;
      });

      activeCustomer = existingUser;

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const CustomerDashboard()));
    } else {
      setState(() => _error = "गलत OTP! कृपया सही OTP दर्ज करें।");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.grey),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminLoginScreen())),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Color(0xFF00D09C),
                child: Icon(Icons.candlestick_chart, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text("Laxmi Trading", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text("अपने मोबाइल नंबर से लॉगिन करें", style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 30),

              if (!_otpSent) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1.5),
                  decoration: const InputDecoration(
                    prefixText: "+91 ",
                    prefixStyle: TextStyle(color: Colors.white, fontSize: 18),
                    labelText: "Mobile Number",
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00D09C))),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D09C)),
                    onPressed: _sendOTP,
                    child: const Text("GET OTP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 4),
                  decoration: InputDecoration(
                    labelText: "Enter OTP (कोई भी 4-6 अंक डालें)",
                    labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00D09C))),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D09C)),
                    onPressed: _verifyOTP,
                    child: const Text("VERIFY & LOGIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _otpSent = false),
                  child: const Text("Change Mobile Number", style: TextStyle(color: Colors.grey)),
                )
              ],

              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(_error, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. ADMIN LOGIN (AJAY)
// ---------------------------------------------------------------------------
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _passController = TextEditingController();
  String _error = "";

  void _verifyAdmin() {
    if (_passController.text.trim() == "Ajay900") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AdminDashboardScreen()));
    } else {
      setState(() => _error = "गलत पासवर्ड! पासवर्ड Ajay900 है।");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajay Admin Control")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.security, size: 60, color: Color(0xFF00D09C)),
            const SizedBox(height: 16),
            TextField(
              controller: _passController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Admin Password", border: OutlineInputBorder()),
            ),
            if (_error.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D09C)),
                onPressed: _verifyAdmin,
                child: const Text("OPEN ADMIN PANEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajay Admin Panel")),
      body: registeredCustomers.isEmpty
          ? const Center(child: Text("अभी कोई कस्टमर पंजीकृत नहीं है।", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: registeredCustomers.length,
              itemBuilder: (context, index) {
                var user = registeredCustomers[index];
                return Card(
                  color: const Color(0xFF1E222D),
                  child: ListTile(
                    title: Text("${user.name} (+91 ${user.phone})", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text("Limit: ₹${user.fundLimit.toStringAsFixed(0)}", style: const TextStyle(color: Color(0xFF00D09C))),
                    trailing: const Icon(Icons.edit, color: Colors.white),
                    onTap: () {
                      TextEditingController c = TextEditingController(text: user.fundLimit.toStringAsFixed(0));
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text("${user.phone} की लिमिट बदलें"),
                          content: TextField(controller: c, keyboardType: TextInputType.number),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() => user.fundLimit = double.parse(c.text));
                                Navigator.pop(ctx);
                              },
                              child: const Text("Save"),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. CUSTOMER DASHBOARD
// ---------------------------------------------------------------------------
class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (mounted && activeCustomer!.positions.isNotEmpty) {
        setState(() {
          for (var p in activeCustomer!.positions) {
            p.currentPrice += (Random().nextBool() ? 0.8 : -0.7);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var user = activeCustomer!;
    double totalPnL = user.positions.fold(0, (s, i) => s + i.pnl);

    return Scaffold(
      appBar: AppBar(
        title: Text("Laxmi Trading (+91 ${user.phone})", style: const TextStyle(fontSize: 15)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const PhoneLoginScreen()));
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00D09C),
          labelColor: const Color(0xFF00D09C),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "INDICES"),
            Tab(text: "STOCKS"),
            Tab(text: "POSITIONS"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // INDICES
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildBalanceCard(user),
              const SizedBox(height: 16),
              _buildIndexItem("NIFTY 50", "24,350.20", 22100, 26400, 50, 25),
              _buildIndexItem("BANK NIFTY", "52,110.50", 43500, 69000, 100, 15),
              _buildIndexItem("SENSEX", "79,820.40", 69100, 86000, 100, 10),
            ],
          ),
          // STOCKS
          ListView.builder(
            itemCount: top50Stocks.length,
            itemBuilder: (c, i) {
              var stock = top50Stocks[i];
              return Card(
                color: const Color(0xFF1E222D),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text(stock.companyName, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("₹${stock.price}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("${stock.change}%", style: TextStyle(color: stock.change >= 0 ? Colors.green : Colors.red, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.show_chart, color: Color(0xFF00D09C)),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => ChartScreen(symbol: stock.symbol, currentPrice: stock.price)));
                  },
                ),
              );
            },
          ),
          // POSITIONS
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1E222D), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Live P&L", style: TextStyle(color: Colors.grey)),
                      Text("₹${totalPnL.toStringAsFixed(2)}", style: TextStyle(color: totalPnL >= 0 ? Colors.green : Colors.red, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: user.positions.length,
                    itemBuilder: (c, i) {
                      var p = user.positions[i];
                      return Card(
                        color: const Color(0xFF1E222D),
                        child: ListTile(
                          title: Text(p.symbol, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: Text("Qty: ${p.quantity} | Buy: ₹${p.buyPrice.toStringAsFixed(2)}"),
                          trailing: Text("₹${p.pnl.toStringAsFixed(2)}", style: TextStyle(color: p.pnl >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBalanceCard(CustomerUser user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF00D09C), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Available Trading Balance", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text("₹${user.fundLimit.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
        ],
      ),
    );
  }

  Widget _buildIndexItem(String name, String price, int start, int end, int step, int lot) {
    return Card(
      color: const Color(0xFF1E222D),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text("Spot: ₹$price"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.candlestick_chart, color: Color(0xFF00D09C)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ChartScreen(symbol: name, currentPrice: double.parse(price.replaceAll(',', ''))))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D09C)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => OptionChainScreen(indexName: name, startStrike: start, endStrike: end, step: step, lotSize: lot, spotPrice: double.parse(price.replaceAll(',', ''))))),
              child: const Text("OPTION CHAIN", style: TextStyle(fontSize: 10, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. OPTION CHAIN & CANDLESTICK CHART
// ---------------------------------------------------------------------------
class OptionChainScreen extends StatelessWidget {
  final String indexName;
  final int startStrike, endStrike, step, lotSize;
  final double spotPrice;

  const OptionChainScreen({super.key, required this.indexName, required this.startStrike, required this.endStrike, required this.step, required this.lotSize, required this.spotPrice});

  @override
  Widget build(BuildContext context) {
    List<int> strikes = [];
    for (int i = startStrike; i <= endStrike; i += step) {
      strikes.add(i);
    }

    return Scaffold(
      appBar: AppBar(title: Text("$indexName Option Chain")),
      body: ListView.builder(
        itemCount: strikes.length,
        itemBuilder: (c, i) {
          int strike = strikes[i];
          double callP = double.parse(((150 + (spotPrice - strike) / 20).clamp(10, 800)).toStringAsFixed(2));
          double putP = double.parse(((150 + (strike - spotPrice) / 20).clamp(10, 800)).toStringAsFixed(2));

          return Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => ChartScreen(symbol: "$indexName $strike CE", currentPrice: callP))),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.green.withOpacity(0.1),
                      child: Text("CE: ₹$callP", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                Container(padding: const EdgeInsets.all(12), child: Text("$strike", style: const TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => ChartScreen(symbol: "$indexName $strike PE", currentPrice: putP))),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.red.withOpacity(0.1),
                      child: Text("PE: ₹$putP", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChartScreen extends StatefulWidget {
  final String symbol;
  final double currentPrice;

  const ChartScreen({super.key, required this.symbol, required this.currentPrice});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<CandleData> candles = [];
  Timer? _chartTimer;
  String selectedTimeframe = "1m";

  @override
  void initState() {
    super.initState();
    _generateDummyCandles();

    _chartTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          double lastClose = candles.last.close;
          double nextClose = lastClose + (Random().nextDouble() * 4 - 2);
          double high = max(lastClose, nextClose) + Random().nextDouble() * 2;
          double low = min(lastClose, nextClose) - Random().nextDouble() * 2;

          candles.removeAt(0);
          candles.add(CandleData(open: lastClose, high: high, low: low, close: nextClose));
        });
      }
    });
  }

  void _generateDummyCandles() {
    double base = widget.currentPrice;
    Random r = Random();
    for (int i = 0; i < 30; i++) {
      double open = base + (r.nextDouble() * 10 - 5);
      double close = open + (r.nextDouble() * 12 - 6);
      double high = max(open, close) + r.nextDouble() * 4;
      double low = min(open, close) - r.nextDouble() * 4;
      candles.add(CandleData(open: open, high: high, low: low, close: close));
      base = close;
    }
  }

  @override
  void dispose() {
    _chartTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double currentPrice = candles.isNotEmpty ? candles.last.close : widget.currentPrice;

    return Scaffold(
      backgroundColor: const Color(0xFF131722),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.symbol, style: const TextStyle(fontSize: 16)),
            Text("₹${currentPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 12, color: Color(0xFF00D09C))),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF1E222D),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["1m", "5m", "15m", "1H", "1D"].map((tf) {
                bool isSelected = tf == selectedTimeframe;
                return InkWell(
                  onTap: () => setState(() => selectedTimeframe = tf),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00D09C) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(tf, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomPaint(
                size: Size.infinite,
                painter: CandlestickPainter(candles: candles),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E222D),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF089981)),
                      onPressed: () => _buyDialog(currentPrice),
                      child: const Text("BUY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF23645)),
                      onPressed: () => _buyDialog(currentPrice),
                      child: const Text("SELL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _buyDialog(double price) {
    TextEditingController qtyController = TextEditingController(text: "50");
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("Execute Order (${widget.symbol})"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Price: ₹${price.toStringAsFixed(2)}"),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter Quantity", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D09C)),
            onPressed: () {
              int qty = int.tryParse(qtyController.text) ?? 50;
              activeCustomer!.positions.add(ActivePosition(symbol: widget.symbol, buyPrice: price, quantity: qty, currentPrice: price));
              Navigator.pop(c);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Executed Successfully!")));
            },
            child: const Text("CONFIRM ORDER", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}

class CandlestickPainter extends CustomPainter {
  final List<CandleData> candles;
  CandlestickPainter({required this.candles});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    double maxHigh = candles.map((c) => c.high).reduce(max);
    double minLow = candles.map((c) => c.low).reduce(min);
    double priceRange = (maxHigh - minLow) == 0 ? 1 : (maxHigh - minLow);
    double candleWidth = size.width / candles.length;

    for (int i = 0; i < candles.length; i++) {
      CandleData candle = candles[i];
      bool isGreen = candle.close >= candle.open;

      Paint paint = Paint()
        ..color = isGreen ? const Color(0xFF089981) : const Color(0xFFF23645)
        ..style = PaintingStyle.fill;

      Paint wickPaint = Paint()
        ..color = isGreen ? const Color(0xFF089981) : const Color(0xFFF23645)
        ..strokeWidth = 1.5;

      double x = i * candleWidth + (candleWidth / 2);
      double highY = size.height - ((candle.high - minLow) / priceRange * size.height);
      double lowY = size.height - ((candle.low - minLow) / priceRange * size.height);
      double openY = size.height - ((candle.open - minLow) / priceRange * size.height);
      double closeY = size.height - ((candle.close - minLow) / priceRange * size.height);

      canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

      double topY = min(openY, closeY);
      double bodyHeight = max((openY - closeY).abs(), 2.0);

      canvas.drawRect(Rect.fromLTWH(x - (candleWidth * 0.3), topY, candleWidth * 0.6, bodyHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CandlestickPainter oldDelegate) => true;
}
