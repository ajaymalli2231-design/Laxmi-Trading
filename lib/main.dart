import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedPhone = prefs.getString('user_phone');
  String? savedName = prefs.getString('user_name');
  String? savedPin = prefs.getString('user_pin');

  db.adminBankName = prefs.getString('admin_bank') ?? "Punjab National Bank";
  db.adminAccountNumber = prefs.getString('admin_acc') ?? "123456789012";
  db.adminIfsc = prefs.getString('admin_ifsc') ?? "PUNB0123456";
  db.adminHolderName = prefs.getString('admin_holder') ?? "Ajay Laxmi Trading";

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
      title: 'Laxmi Trading',
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
  final Map<String, Map<String, String>> userBankDetails = {};

  String adminBankName = "Punjab National Bank";
  String adminAccountNumber = "123456789012";
  String adminIfsc = "PUNB0123456";
  String adminHolderName = "Ajay Laxmi Trading";
}

final AppDatabase db = AppDatabase();

class TradePosition {
  final String symbol;
  final String type;
  final double entryPrice;
  double currentPrice;
  final int qty;

  TradePosition({
    required this.symbol,
    required this.type,
    required this.entryPrice,
    required this.currentPrice,
    required this.qty,
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया सही नाम और मोबाइल नंबर दर्ज करें!')));
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
                const Text('Laxmi Trading Login', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'पूरा नाम (Full Name)', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: 'मोबाइल नंबर (Mobile)', prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'पासवर्ड (Admin Code optional)', prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    onPressed: handleNext,
                    child: const Text('आगे बढ़ें (Set PIN)', style: TextStyle(fontSize: 16, color: Colors.white)),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('पिन ठीक 4 अंकों का होना चाहिए!')));
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
              const Text('4-Digit PIN बनाएं', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: InputDecoration(labelText: '4 अंकों का गुप्त पिन', prefixIcon: const Icon(Icons.vpn_key), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: savePin,
                  child: const Text('पिन सेव करें और ऐप खोलें', style: TextStyle(fontSize: 16, color: Colors.white)),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('गलत पिन दर्ज किया गया है!')));
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
              const Text('पिन दर्ज करें', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('स्वागत है, ${widget.userName}', style: const TextStyle(color: Colors.grey)),
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
                  child: const Text('अनलॉक करें', style: TextStyle(fontSize: 16, color: Colors.white)),
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

    final List<Widget> pages = [
      buildWatchlistTab(currentFund),
      PositionsTab(userPhone: widget.userPhone),
      UserDepositTab(userPhone: widget.userPhone),
      AccountTab(userName: widget.userName, userPhone: widget.userPhone, currentFund: currentFund),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laxmi Trading Live', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget buildWatchlistTab(double currentFund) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          color: const Color(0xFF1E293B),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('यूजर: ${widget.userName}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text('कैपिटल: ₹${currentFund.toStringAsFixed(2)}', 
                style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                title: const Text('NIFTY 50 (Option Chain & Live Chart)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                subtitle: const Text('चार्ट और बाय/सेल विकल्प देखने के लिए क्लिक करें'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GenericOptionChainScreen(indexName: 'NIFTY 50', userPhone: widget.userPhone, spotPrice: 23431.0, minStrike: 21900, maxStrike: 26200, lotSize: 50))),
              ),
              const Divider(color: Colors.white12),
              ListTile(
                title: const Text('BANK NIFTY (Option Chain & Live Chart)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlueAccent)),
                subtitle: const Text('चार्ट और बाय/सेल विकल्प देखने के लिए क्लिक करें'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GenericOptionChainScreen(indexName: 'BANK NIFTY', userPhone: widget.userPhone, spotPrice: 56450.0, minStrike: 43500, maxStrike: 69000, lotSize: 15))),
              ),
              const Divider(color: Colors.white12),
              ListTile(
                title: const Text('SENSEX (Option Chain & Live Chart)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                subtitle: const Text('चार्ट और बाय/सेल विकल्प देखने के लिए क्लिक करें'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GenericOptionChainScreen(indexName: 'SENSEX', userPhone: widget.userPhone, spotPrice: 81250.0, minStrike: 68600, maxStrike: 86000, lotSize: 10))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GenericOptionChainScreen extends StatefulWidget {
  final String indexName;
  final String userPhone;
  final double spotPrice;
  final double minStrike;
  final double maxStrike;
  final int lotSize;

  const GenericOptionChainScreen({
    super.key,
    required this.indexName,
    required this.userPhone,
    required this.spotPrice,
    required this.minStrike,
    required this.maxStrike,
    required this.lotSize,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${widget.indexName} ${strike.toInt()} $type', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text('लाइव प्रीमियम: ₹${price.toStringAsFixed(2)} | लॉट: ${widget.lotSize}', style: const TextStyle(color: Colors.amberAccent, fontSize: 14)),
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
                          qty: widget.lotSize,
                        ));
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('BUY आर्डर Positions में जुड़ गया है!')));
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
                          qty: widget.lotSize,
                        ));
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SELL आर्डर Positions में जुड़ गया है!')));
                    },
                    child: const Text('SELL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.indexName} Option Chain'), backgroundColor: const Color(0xFF1E293B)),
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
              Text('कुल कैपिटल: ₹${currentFund.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              Text('लाइव P&L: ₹${totalPnl.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: totalPnl >= 0 ? Colors.greenAccent : Colors.redAccent)),
            ],
          ),
        ),
        Expanded(
          child: positions.isEmpty
              ? const Center(child: Text('कोई एक्टिव पोजीशन नहीं है।', style: TextStyle(color: Colors.grey)))
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
                                Text(pos.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(pos.type, style: TextStyle(color: pos.type == 'BUY' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('प्रवेश मूल्य: ₹${pos.entryPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
                                Text('प्रॉफिट/लॉस: ₹${pos.pnl.toStringAsFixed(2)}', style: TextStyle(color: isProfit ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
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
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ट्रेड बंद कर दिया गया और P&L कैपिटल में जुड़ गया!')));
                                },
                                child: const Text('Exit Position (ट्रेड बंद करें)', style: TextStyle(color: Colors.white)),
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
  const UserDepositTab({super.key, required this.userPhone});

  @override
  State<UserDepositTab> createState() => _UserDepositTabState();
}

class _UserDepositTabState extends State<UserDepositTab> {
  final TextEditingController userBankNameController = TextEditingController();
  final TextEditingController userAccNoController = TextEditingController();
  final TextEditingController userIfscController = TextEditingController();
  final TextEditingController userHolderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var savedBank = db.userBankDetails[widget.userPhone];
    if (savedBank != null) {
      userBankNameController.text = savedBank['bank'] ?? '';
      userAccNoController.text = savedBank['acc'] ?? '';
      userIfscController.text = savedBank['ifsc'] ?? '';
      userHolderController.text = savedBank['holder'] ?? '';
    }
  }

  void _saveUserBank() {
    String bank = userBankNameController.text.trim();
    String acc = userAccNoController.text.trim();
    String ifsc = userIfscController.text.trim();
    String holder = userHolderController.text.trim();

    if (bank.isNotEmpty && acc.isNotEmpty && ifsc.isNotEmpty) {
      db.userBankDetails[widget.userPhone] = {
        'bank': bank,
        'acc': acc,
        'ifsc': ifsc,
        'holder': holder,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('आपका डिपॉजिट बैंक अकाउंट सफलतापूर्वक सेव हो गया है!')),
      );
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया सभी बैंक विवरण सही से भरें!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var userBank = db.userBankDetails[widget.userPhone];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('फंड्स डिपॉजिट के लिए अपना बैंक अकाउंट जोड़ें', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          const SizedBox(height: 10),
          TextField(
            controller: userBankNameController,
            decoration: const InputDecoration(labelText: 'बैंक का नाम (Bank Name)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: userAccNoController,
            decoration: const InputDecoration(labelText: 'खाता नंबर (Account Number)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: userIfscController,
            decoration: const InputDecoration(labelText: 'IFSC कोड', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: userHolderController,
            decoration: const InputDecoration(labelText: 'खाता धारक का नाम (Holder Name)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _saveUserBank,
              child: const Text('डिपॉजिट बैंक सेव करें', style: TextStyle(color: Colors.white)),
            ),
          ),
          if (userBank != null) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
              child: Text('सेव्ड बैंक: ${userBank['bank']} | A/c: ${userBank['acc']}', style: const TextStyle(color: Colors.lightGreenAccent, fontSize: 13)),
            ),
          ],
          const SizedBox(height: 25),
          const Text('नोट: यूजर केवल डिपॉजिट करने के लिए अपना बैंक जोड़ सकता है। विथड्रॉल केवल एडमिन (अजय) द्वारा पासवर्ड से किया जाएगा।', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
          const Text('यूजर अकाउंट विवरण', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('नाम: $userName', style: const TextStyle(fontSize: 16)),
          Text('मोबाइल नंबर: $userPhone', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Text('उपलब्ध कैपिटल: ₹${currentFund.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
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
  final TextEditingController bankNameController = TextEditingController(text: db.adminBankName);
  final TextEditingController accNoController = TextEditingController(text: db.adminAccountNumber);
  final TextEditingController ifscController = TextEditingController(text: db.adminIfsc);
  final TextEditingController holderController = TextEditingController(text: db.adminHolderName);

  final TextEditingController targetPhoneController = TextEditingController();
  final TextEditingController withdrawAmtController = TextEditingController();
  final TextEditingController adminPasswordController = TextEditingController();

  void _saveAdminBank() async {
    setState(() {
      db.adminBankName = bankNameController.text.trim();
      db.adminAccountNumber = accNoController.text.trim();
      db.adminIfsc = ifscController.text.trim();
      db.adminHolderName = holderController.text.trim();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_bank', db.adminBankName);
    await prefs.setString('admin_acc', db.adminAccountNumber);
    await prefs.setString('admin_ifsc', db.adminIfsc);
    await prefs.setString('admin_holder', db.adminHolderName);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('अजय का बैंक अकाउंट अपडेट कर दिया गया!')),
    );
  }

  void _processAdminWithdrawal() {
    String phone = targetPhoneController.text.trim();
    double amt = double.tryParse(withdrawAmtController.text.trim()) ?? 0;
    String password = adminPasswordController.text.trim();

    if (password != "Ajay900") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('गलत पासवर्ड! विथड्रॉल केवल अजय के पासवर्ड से संभव है।')),
      );
      return;
    }

    if (!db.customerFunds.containsKey(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('यूजर का यह मोबाइल नंबर नहीं मिला!')),
      );
      return;
    }

    double currentFund = db.customerFunds[phone] ?? 0;
    if (amt <= 0 || amt > currentFund) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('गलत विथड्रॉल राशि या पर्याप्त फंड नहीं है!')),
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
        title: const Text('विथड्रॉल सफल'),
        content: Text('यूजर ($phone) के अकाउंट से ₹$amt काटकर अजय के बैंक अकाउंट (${db.adminBankName}) में ट्रांसफर कर दिए गए हैं।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ठीक है', style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> phones = db.customerNames.keys.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Ajay Master Admin Panel (Withdrawal Control)'), backgroundColor: const Color(0xFF1E293B)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('1. अजय का बैंक अकाउंट मैनेज करें', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          const SizedBox(height: 10),
          TextField(
            controller: bankNameController,
            decoration: const InputDecoration(labelText: 'बैंक का नाम (Bank Name)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: accNoController,
            decoration: const InputDecoration(labelText: 'खाता नंबर (Account Number)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: ifscController,
            decoration: const InputDecoration(labelText: 'IFSC कोड', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: holderController,
            decoration: const InputDecoration(labelText: 'अकाउंट धारक का नाम (Holder Name)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: _saveAdminBank,
            child: const Text('बैंक विवरण सेव करें', style: TextStyle(color: Colors.white)),
          ),
          const Divider(height: 40, color: Colors.white24),
          const Text('2. पासवर्ड के साथ यूजर का विथड्रॉल करें (Admin Only)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
          const SizedBox(height: 10),
          TextField(
            controller: targetPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'यूजर का मोबाइल नंबर (User Mobile)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: withdrawAmtController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'विथड्रॉल राशि (Withdraw Amount ₹)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: adminPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'अजय का पासवर्ड (Admin Password: Ajay900)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: _processAdminWithdrawal,
            child: const Text('पासवर्ड डालकर विथड्रॉल प्रोसेस करें', style: TextStyle(color: Colors.white)),
          ),
          const Divider(height: 40, color: Colors.white24),
          const Text('रजिस्टर्ड यूजर्स लिस्ट और फंड्स', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: phones.length,
              itemBuilder: (context, index) {
                String p = phones[index];
                return ListTile(
         title: Text(db.customerNames[p] ?? ''),
                  subtitle: Text('Mobile: $p | फंड्स: ₹${db.customerFunds[p]}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
