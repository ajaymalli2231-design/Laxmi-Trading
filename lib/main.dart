import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedPhone = prefs.getString('user_phone');
  String? savedName = prefs.getString('user_name');
  String? savedPin = prefs.getString('user_pin');

  db.adminUpiId = prefs.getString('admin_upi') ?? "ajaymalli@paytm";

  runApp(LaxmiTradingApp(savedPhone: savedPhone, savedName: savedName, savedPin: savedPin));
}

class LaxmiTradingApp extends StatelessWidget {
  final String? savedPhone;
  final String? savedName;
  final String? savedPin;

  const LaxmiTradingApp({super.key, this.savedPhone, this.savedName, this.savedPin});

  @override
  Widget build(BuildContext context) {
    Widget initialScreen;
    if (savedPhone != null && savedName != null) {
      if (savedPin != null) {
        initialScreen = PinLockScreen(userName: savedName!, userPhone: savedPhone!, correctPin: savedPin!);
      } else {
        initialScreen = PinSetupScreen(userName: savedName!, userPhone: savedPhone!);
      }
    } else {
      initialScreen = const LoginScreen();
    }

    return MaterialApp(
      title: 'Laxmi Trading Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primarySwatch: Colors.blue,
      ),
      home: initialScreen,
    );
  }
}

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  final Map<String, double> customerFunds = {};
  final Map<String, String> customerNames = {};
  final Map<String, List<TradePosition>> userPositions = {};
  String adminUpiId = "ajaymalli@paytm";
}

final AppDatabase db = AppDatabase();

// --- Market Timing Check (Monday-Friday, 9:15 AM to 3:30 PM) ---
bool isMarketOpen() {
  DateTime now = DateTime.now();
  if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
    return false;
  }
  int hour = now.hour;
  int minute = now.minute;
  int totalMinutes = hour * 60 + minute;
  int marketOpenMinutes = 9 * 60 + 15; // 09:15 AM
  int marketCloseMinutes = 15 * 60 + 30; // 03:30 PM
  return totalMinutes >= marketOpenMinutes && totalMinutes <= marketCloseMinutes;
}

// --- Real Expiry Date Generator (Current Week Thursday) ---
String getRealExpiry(String indexName) {
  DateTime now = DateTime.now();
  int daysUntilThursday = (DateTime.thursday - now.weekday) % 7;
  if (daysUntilThursday == 0 && now.hour >= 15 && now.minute >= 30) {
    daysUntilThursday = 7;
  }
  DateTime nextExpiry = now.add(Duration(days: daysUntilThursday));
  return "${nextExpiry.day}-${nextExpiry.month}-${nextExpiry.year}";
}

class TradePosition {
  final String symbol;
  final String type;
  final double entryPrice;
  double currentPrice;
  final int qty;
  final String expiryDate;

  TradePosition({
    required this.symbol,
    required this.type,
    required this.entryPrice,
    required this.currentPrice,
    required this.qty,
    required this.expiryDate,
  });

  double get pnl {
    double diff = currentPrice - entryPrice;
    if (type == 'SELL') diff = entryPrice - currentPrice;
    return diff * qty;
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void handleNext() async {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();

    if (password == "Ajay900") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
      return;
    }

    if (name.isNotEmpty && phone.length >= 10) {
      db.customerNames[phone] = name;
      if (!db.customerFunds.containsKey(phone)) {
        db.customerFunds[phone] = 10000.0;
        db.userPositions[phone] = [];
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_phone', phone);
      await prefs.setString('user_name', name);

      if(!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PinSetupScreen(userName: name, userPhone: phone)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid name and mobile number!')));
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
                const Text('Laxmi Trading Pro', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Full Name', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: 'Mobile Number', prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password (Admin Code Optional)', prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    onPressed: handleNext,
                    child: const Text('Next (Set PIN)', style: TextStyle(fontSize: 16, color: Colors.white)),
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

class PinSetupScreen extends StatefulWidget {
  final String userName;
  final String userPhone;
  const PinSetupScreen({super.key, required this.userName, required this.userPhone});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final TextEditingController pinController = TextEditingController();

  void savePin() async {
    String pin = pinController.text.trim();
    if (pin.length == 4) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_pin', pin);
      if(!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainDashboard(userName: widget.userName, userPhone: widget.userPhone)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN must be exactly 4 digits!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.greenAccent),
              const SizedBox(height: 10),
              const Text('Create 4-Digit PIN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: InputDecoration(labelText: '4-Digit Secret PIN', prefixIcon: const Icon(Icons.vpn_key), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: savePin,
                  child: const Text('Save PIN & Open App', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PinLockScreen extends StatefulWidget {
  final String userName;
  final String userPhone;
  final String correctPin;

  const PinLockScreen({super.key, required this.userName, required this.userPhone, required this.correctPin});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController pinController = TextEditingController();

  void verifyPin() {
    if (pinController.text.trim() == widget.correctPin) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainDashboard(userName: widget.userName, userPhone: widget.userPhone)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect PIN entered!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 10),
              const Text('Enter PIN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Welcome, ${widget.userName}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: InputDecoration(labelText: '4-Digit PIN', prefixIcon: const Icon(Icons.lock_open), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: verifyPin,
                  child: const Text('Unlock', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainDashboard extends StatefulWidget {
  final String userName;
  final String userPhone;
  const MainDashboard({super.key, required this.userName, required this.userPhone});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    db.customerNames[widget.userPhone] = widget.userName;
    if (!db.customerFunds.containsKey(widget.userPhone)) {
      db.customerFunds[widget.userPhone] = 10000.0;
      db.userPositions[widget.userPhone] = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    double currentFund = db.customerFunds[widget.userPhone] ?? 10000.0;
    bool marketActive = isMarketOpen();

    final List<Widget> pages = [
      buildWatchlistTab(currentFund, marketActive),
      PositionsTab(userPhone: widget.userPhone),
      UserDepositTab(userPhone: widget.userPhone, userName: widget.userName),
      AccountTab(userName: widget.userName, userPhone: widget.userPhone, currentFund: currentFund),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Laxmi Trading Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: marketActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: marketActive ? Colors.green : Colors.red),
              ),
              child: Text(
                marketActive ? '● MARKET LIVE' : '■ MARKET CLOSED',
                style: TextStyle(fontSize: 10, color: marketActive ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
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
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Positions'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Deposit'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }

  Widget buildWatchlistTab(double currentFund, bool marketActive) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          color: const Color(0xFF1E293B),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('User: ${widget.userName}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text('Capital: ₹${currentFund.toStringAsFixed(2)}', 
                style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _buildWatchlistTile('NIFTY 50', 23431.0, 21900, 26200, 50, Colors.blueAccent, marketActive),
              const Divider(color: Colors.white12),
              _buildWatchlistTile('BANK NIFTY', 56450.0, 43500, 69000, 15, Colors.lightBlueAccent, marketActive),
              const Divider(color: Colors.white12),
              _buildWatchlistTile('SENSEX', 81250.0, 68600, 86000, 10, Colors.amberAccent, marketActive),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWatchlistTile(String name, double spot, double minS, double maxS, int lot, Color color, bool marketActive) {
    return ListTile(
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      subtitle: Text('Expiry: ${getRealExpiry(name)} | Lot Size: $lot'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.show_chart, color: Colors.greenAccent),
            tooltip: 'Live Chart',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LiveChartScreen(indexName: name, spotPrice: spot)));
            },
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => GenericOptionChainScreen(indexName: name, userPhone: widget.userPhone, spotPrice: spot, minStrike: minS, maxStrike: maxS, lotSize: lot, marketActive: marketActive)));
      },
    );
  }
}

// --- Live Chart Screen ---
class LiveChartScreen extends StatefulWidget {
  final String indexName;
  final double spotPrice;
  const LiveChartScreen({super.key, required this.indexName, required this.spotPrice});

  @override
  State<LiveChartScreen> createState() => _LiveChartScreenState();
}

class _LiveChartScreenState extends State<LiveChartScreen> {
  late double currentPrice;
  final List<double> priceHistory = [];
  late Timer timer;

  @override
  void initState() {
    super.initState();
    currentPrice = widget.spotPrice;
    for (int i = 0; i < 20; i++) {
      priceHistory.add(currentPrice + (Random().nextDouble() - 0.5) * 10);
    }
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        currentPrice += (Random().nextDouble() - 0.49) * 8;
        priceHistory.add(currentPrice);
        if (priceHistory.length > 30) priceHistory.removeAt(0);
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.indexName} Live Chart'), backgroundColor: const Color(0xFF1E293B)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.indexName} LTP: ₹${currentPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
            const Text('Real-time Candlestick Simulator', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
                child: CustomPaint(
                  painter: ChartPainter(priceHistory),
                  child: const Container(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<double> prices;
  ChartPainter(this.prices);

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) return;
    Paint paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    double minP = prices.reduce((a, b) => a < b ? a : b);
    double maxP = prices.reduce((a, b) => a > b ? a : b);
    double range = (maxP - minP) == 0 ? 1 : (maxP - minP);

    Path path = Path();
    for (int i = 0; i < prices.length; i++) {
      double x = (i / (prices.length - 1)) * size.width;
      double y = size.height - ((prices[i] - minP) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GenericOptionChainScreen extends StatefulWidget {
  final String indexName;
  final String userPhone;
  final double spotPrice;
  final double minStrike;
  final double maxStrike;
  final int lotSize;
  final bool marketActive;

  const GenericOptionChainScreen({
    super.key,
    required this.indexName,
    required this.userPhone,
    required this.spotPrice,
    required this.minStrike,
    required this.maxStrike,
    required this.lotSize,
    required this.marketActive,
  });

  @override
  State<GenericOptionChainScreen> createState() => _GenericOptionChainScreenState();
}

class ChainRowData {
  final double strikePrice;
  double callPrice;
  double putPrice;
  ChainRowData({required this.strikePrice, required this.callPrice, required this.putPrice});
}

class _GenericOptionChainScreenState extends State<GenericOptionChainScreen> {
  late double currentSpot;
  List<ChainRowData> chainList = [];
  late Timer timer;

  @override
  void initState() {
    super.initState();
    currentSpot = widget.spotPrice;
    _generateChain();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        currentSpot += (Random().nextDouble() - 0.49) * 6;
        for (var item in chainList) {
          if (item.strikePrice < currentSpot) {
            item.callPrice += (Random().nextDouble() - 0.48) * 2;
          } else {
            item.putPrice += (Random().nextDouble() - 0.48) * 2;
          }
          if (item.callPrice < 0.05) item.callPrice = 0.05;
          if (item.putPrice < 0.05) item.putPrice = 0.05;
        }
      });
    });
  }

  void _generateChain() {
    for (double strike = widget.minStrike; strike <= widget.maxStrike; strike += 100) {
      chainList.add(ChainRowData(
        strikePrice: strike, 
        callPrice: Random().nextDouble() * 100 + 40, 
        putPrice: Random().nextDouble() * 100 + 40,
      ));
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _openTradeModal(double strike, String type, double price) {
    if (!widget.marketActive) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Market is closed! Cannot trade right now.')));
      return;
    }

    int currentLotsCount = 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          int totalQty = currentLotsCount * widget.lotSize;
          double totalAmountNeeded = price * totalQty;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${widget.indexName} ${strike.toInt()} $type', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text('Expiry: ${getRealExpiry(widget.indexName)} | Premium: ₹${price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amberAccent, fontSize: 13)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Lots: ', style: TextStyle(fontSize: 15)),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 30),
                      onPressed: () {
                        if (currentLotsCount > 1) {
                          setModalState(() => currentLotsCount--);
                        }
                      },
                    ),
                    Text('$currentLotsCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.greenAccent, size: 30),
                      onPressed: () {
                        setModalState(() => currentLotsCount++);
                      },
                    ),
                  ],
                ),
                Text('Total Qty: $totalQty shares (Est. Cost: ₹${totalAmountNeeded.toStringAsFixed(2)})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () {
                          setState(() {
                            db.userPositions[widget.userPhone]?.add(TradePosition(
                              symbol: '${widget.indexName} ${strike.toInt()} $type', 
                              type: 'BUY', 
                              entryPrice: price, 
                              currentPrice: price, 
                              qty: totalQty,
                              expiryDate: getRealExpiry(widget.indexName),
                            ));
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('BUY order ($totalQty Qty) added to Positions!')));
                        },
                        child: const Text('BUY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          setState(() {
                            db.userPositions[widget.userPhone]?.add(TradePosition(
                              symbol: '${widget.indexName} ${strike.toInt()} $type', 
                              type: 'SELL', 
                              entryPrice: price, 
                              currentPrice: price, 
                              qty: totalQty,
                              expiryDate: getRealExpiry(widget.indexName),
                            ));
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SELL order ($totalQty Qty) added to Positions!')));
                        },
                        child: const Text('SELL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${widget.indexName} Option Chain'),
            IconButton(
              icon: const Icon(Icons.show_chart, color: Colors.greenAccent),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LiveChartScreen(indexName: widget.indexName, spotPrice: currentSpot))),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: const Color(0xFF162032),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CE Price', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('Spot: ${currentSpot.toStringAsFixed(2)}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                const Text('PE Price', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chainList.length,
              itemBuilder: (context, index) {
                var item = chainList[index];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _openTradeModal(item.strikePrice, 'CE', item.callPrice),
                        child: Text('₹${item.callPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(6)),
                        child: Text('${item.strikePrice.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      GestureDetector(
                        onTap: () => _openTradeModal(item.strikePrice, 'PE', item.putPrice),
                        child: Text('₹${item.putPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PositionsTab extends StatefulWidget {
  final String userPhone;
  const PositionsTab({super.key, required this.userPhone});

  @override
  State<PositionsTab> createState() => _PositionsTabState();
}

class _PositionsTabState extends State<PositionsTab> {
  late Timer refreshTimer;

  @override
  void initState() {
    super.initState();
    refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        List<TradePosition>? positions = db.userPositions[widget.userPhone];
        if (positions != null) {
          for (var pos in positions) {
            pos.currentPrice += (Random().nextDouble() - 0.49) * 2;
            if (pos.currentPrice < 0.05) pos.currentPrice = 0.05;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<TradePosition> positions = db.userPositions[widget.userPhone] ?? [];
    double currentFund = db.customerFunds[widget.userPhone] ?? 10000.0;
    
    double totalPnl = 0;
    for (var p in positions) {
      totalPnl += p.pnl;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF1E293B),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Capital: ₹${currentFund.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              Text('Live P&L: ₹${totalPnl.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: totalPnl >= 0 ? Colors.greenAccent : Colors.redAccent)),
            ],
          ),
        ),
        Expanded(
          child: positions.isEmpty
              ? const Center(child: Text('No active positions found.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: positions.length,
                  itemBuilder: (context, index) {
                    TradePosition pos = positions[index];
                    bool isProfit = pos.pnl >= 0;

                    return Card(
                      color: const Color(0xFF1E293B),
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(pos.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Text(pos.type, style: TextStyle(color: pos.type == 'BUY' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Expiry: ${pos.expiryDate} | Qty: ${pos.qty}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Entry Price: ₹${pos.entryPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
                                Text('P&L: ₹${pos.pnl.toStringAsFixed(2)}', style: TextStyle(color: isProfit ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    db.customerFunds[widget.userPhone] = (db.customerFunds[widget.userPhone] ?? 10000) + pos.pnl;
                                    positions.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Position closed and P&L added to capital!')));
                                },
                                child: const Text('Exit Position', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class UserDepositTab extends StatefulWidget {
  final String userPhone;
  final String userName;
  const UserDepositTab({super.key, required this.userPhone, required this.userName});

  @override
  State<UserDepositTab> createState() => _UserDepositTabState();
}

class _UserDepositTabState extends State<UserDepositTab> {
  final TextEditingController amountController = TextEditingController();

  Future<void> _payWithUpi() async {
    String amtText = amountController.text.trim();
    if (amtText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an amount!')));
      return;
    }

    double? amount = double.tryParse(amtText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount!')));
      return;
    }

    String upiUrl = 'upi://pay?pa=${db.adminUpiId}&pn=LaxmiTrading&am=$amount&cu=INR';
    final Uri uri = Uri.parse(upiUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _showPaymentSuccessDialog(amount);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No UPI app found on your phone!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showPaymentSuccessDialog(double amount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Was payment successful?'),
        content: Text('If you have successfully paid ₹$amount, click "Yes" to add funds to your trading account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              setState(() {
                double current = db.customerFunds[widget.userPhone] ?? 10000.0;
                db.customerFunds[widget.userPhone] = current + amount;
              });
              Navigator.pop(ctx);
              amountController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Successfully added ₹$amount to your trading capital!')),
              );
            },
            child: const Text('Yes, Add Funds', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double currentFund = db.customerFunds[widget.userPhone] ?? 10000.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Real Money via UPI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          const SizedBox(height: 5),
          Text('Admin UPI ID: ${db.adminUpiId}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter Amount to Add (₹)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: _payWithUpi,
              child: const Text('Pay via GPay / PhonePe & Add Funds', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Trading Capital:', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 5),
                Text('₹${currentFund.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AccountTab extends StatelessWidget {
  final String userName;
  final String userPhone;
  final double currentFund;
  const AccountTab({super.key, required this.userName, required this.userPhone, required this.currentFund});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Account Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Name: $userName', style: const TextStyle(fontSize: 16)),
          Text('Mobile Number: $userPhone', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Text('Available Capital: ₹${currentFund.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController upiController = TextEditingController(text: db.adminUpiId);
  final TextEditingController targetPhoneController = TextEditingController();
  final TextEditingController withdrawAmtController = TextEditingController();
  final TextEditingController adminPasswordController = TextEditingController();

  void _saveAdminUpi() async {
    setState(() {
      db.adminUpiId = upiController.text.trim();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_upi', db.adminUpiId);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin UPI ID successfully updated!')),
    );
  }

  void _processAdminWithdrawal() {
    String phone = targetPhoneController.text.trim();
    double amt = double.tryParse(withdrawAmtController.text.trim()) ?? 0;
    String password = adminPasswordController.text.trim();

    if (password != "Ajay900") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect password! Withdrawal requires admin password.')),
      );
      return;
    }

    if (!db.customerFunds.containsKey(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User mobile number not found!')),
      );
      return;
    }

    double currentFund = db.customerFunds[phone] ?? 0;
    if (amt <= 0 || amt > currentFund) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid withdrawal amount or insufficient funds!')),
      );
      return;
    }

    setState(() {
      db.customerFunds[phone] = currentFund - amt;
    });

    targetPhoneController.clear();
    withdrawAmtController.clear();
    adminPasswordController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Withdrawal Successful'),
        content: Text('₹$amt has been deducted from user ($phone) and transferred to admin UPI (${db.adminUpiId}).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> phones = db.customerNames.keys.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Ajay Master Admin Panel'), backgroundColor: const Color(0xFF1E293B)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('1. Set Admin UPI ID', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          const SizedBox(height: 10),
          TextField(
            controller: upiController,
            decoration: const InputDecoration(labelText: 'UPI ID (e.g. yourname@paytm)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: _saveAdminUpi,
            child: const Text('Save UPI ID', style: TextStyle(color: Colors.white)),
          ),
          const Divider(height: 40, color: Colors.white24),
          const Text('2. Process User Withdrawal with Password (Admin Only)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
          const SizedBox(height: 10),
          TextField(
            controller: targetPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'User Mobile Number', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: withdrawAmtController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Withdraw Amount (₹)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: adminPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Admin Password (Password: Ajay900)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: _processAdminWithdrawal,
            child: const Text('Process Withdrawal with Password', style: TextStyle(color: Colors.white)),
          ),
          const Divider(height: 40, color: Colors.white24),
          const Text('Registered Users & Funds List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: phones.length,
              itemBuilder: (context, index) {
                String p = phones[index];
                return ListTile(
                  title: Text(db.customerNames[p] ?? ''),
                  subtitle: Text('Mobile: $p | Funds: ₹${db.customerFunds[p]}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
