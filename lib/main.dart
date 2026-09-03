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

class IndexData {
  final String symbol;
  double spotPrice;
  double change;
  final int minStrike;
  final int maxStrike;
  final int step;
  final int lotSize;

  IndexData({
    required this.symbol,
    required this.spotPrice,
    required this.change,
    required this.minStrike,
    required this.maxStrike,
    required this.step,
    required this.lotSize,
  });
}

Map<String, IndexData> globalIndices = {
  "NIFTY 50": IndexData(symbol: "NIFTY 50", spotPrice: 23873.45, change: -41.00, minStrike: 22100, maxStrike: 26400, step: 50, lotSize: 50),
  "BANKNIFTY": IndexData(symbol: "BANKNIFTY", spotPrice: 48933.69, change: -131.61, minStrike: 43500, maxStrike: 69000, step: 100, lotSize: 15),
  "SENSEX": IndexData(symbol: "SENSEX", spotPrice: 78500.20, change: 120.50, minStrike: 69100, maxStrike: 86000, step: 100, lotSize: 10),
  "FINNIFTY": IndexData(symbol: "FINNIFTY", spotPrice: 21450.10, change: 15.30, minStrike: 20000, maxStrike: 23500, step: 50, lotSize: 40),
  "MIDCPNIFTY": IndexData(symbol: "MIDCPNIFTY", spotPrice: 12300.80, change: -22.10, minStrike: 11000, maxStrike: 13500, step: 25, lotSize: 75),
};

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
  bool _isMarketOpen = false;

  @override
  void initState() {
    super.initState();
    _checkMarketTimeAndTick();
    _marketTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkMarketTimeAndTick();
    });
  }

  void _checkMarketTimeAndTick() {
    DateTime now = DateTime.now();
    bool isWeekday = now.weekday >= 1 && now.weekday <= 5;
    int currentMinutes = now.hour * 60 + now.minute;
    int openMinutes = 9 * 60 + 15;
    int closeMinutes = 15 * 60 + 30;

    bool marketOpenNow = isWeekday && (currentMinutes >= openMinutes && currentMinutes <= closeMinutes);

    if (mounted) {
      setState(() {
        _isMarketOpen = marketOpenNow;
        if (_isMarketOpen) {
          globalIndices.forEach((key, indexData) {
            double tick = (_rnd.nextDouble() * 4 - 2.0);
            indexData.spotPrice += tick;
            indexData.change += tick;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _marketTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      MarketWatchScreen(user: widget.user, isMarketOpen: _isMarketOpen),
      OptionChainScreen(user: widget.user, isMarketOpen: _isMarketOpen),
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
            Row(
              children: [
                Text(widget.user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _isMarketOpen ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _isMarketOpen ? Colors.green : Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: _isMarketOpen ? Colors.green : Colors.red),
                      const SizedBox(width: 4),
                      Text(_isMarketOpen ? "LIVE" : "CLOSED", style: TextStyle(fontSize: 10, color: _isMarketOpen ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
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
          const BottomNavigationBarItem(icon: Icon(Icons.table_chart_rounded), label: 'Option Chain'),
          const BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Positions'),
          const BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          if (widget.user.isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }
}

// OPTION CHAIN SCREEN
class OptionChainScreen extends StatefulWidget {
  final UserAccount user;
  final bool isMarketOpen;

  const OptionChainScreen({super.key, required this.user, required this.isMarketOpen});

  @override
  State<OptionChainScreen> createState() => _OptionChainScreenState();
}

class _OptionChainScreenState extends State<OptionChainScreen> {
  String selectedSymbol = "NIFTY 50";

  void _buyOption(String optionSymbol, double price, int lotSize) {
    if (!widget.isMarketOpen) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Market is closed! Cannot place order outside market hours.')));
      return;
    }

    double margin = lotSize * price;

    if (margin > widget.user.balance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient Wallet Balance!')));
      return;
    }

    globalPositions.add(PositionItem(
      symbol: optionSymbol,
      lots: 1,
      lotSize: lotSize,
      buyPrice: price,
      type: 'BUY',
    ));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text('BUY Order Executed for $optionSymbol @ ₹${price.toStringAsFixed(2)}!')));
  }

  // Realistic Options Price Modeling (Black-Scholes Approximation)
  double _calculateCallPrice(double spot, int strike) {
    double diff = spot - strike;
    if (diff > 0) {
      return diff + (spot * 0.005);
    } else {
      return max(2.50, (spot * 0.005) * exp(diff / (spot * 0.02)));
    }
  }

  double _calculatePutPrice(double spot, int strike) {
    double diff = strike - spot;
    if (diff > 0) {
      return diff + (spot * 0.005);
    } else {
      return max(2.50, (spot * 0.005) * exp(-diff / (spot * 0.02)));
    }
  }

  @override
  Widget build(BuildContext context) {
    IndexData indexData = globalIndices[selectedSymbol]!;
    List<int> strikes = [];
    for (int s = indexData.minStrike; s <= indexData.maxStrike; s += indexData.step) {
      strikes.add(s);
    }

    return Column(
      children: [
        if (!widget.isMarketOpen)
          Container(
            width: double.infinity,
            color: Colors.redAccent.withOpacity(0.15),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: const Text(
              "MARKET IS CLOSED (Hours: Mon-Fri, 9:15 AM - 3:30 PM IST)",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        
        // Index Selector Header
        Container(
          color: const Color(0xFF151D2A),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: selectedSymbol,
                dropdownColor: const Color(0xFF151D2A),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                underline: Container(),
                items: globalIndices.keys.map((String symbol) {
                  return DropdownMenuItem<String>(
                    value: symbol,
                    child: Text(symbol),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedSymbol = val);
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("₹${indexData.spotPrice.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: indexData.change >= 0 ? Colors.greenAccent : Colors.redAccent)),
                  Text("${indexData.change >= 0 ? '+' : ''}${indexData.change.toStringAsFixed(2)}", style: TextStyle(fontSize: 11, color: indexData.change >= 0 ? Colors.greenAccent : Colors.redAccent)),
                ],
              )
            ],
          ),
        ),

        // Chain Headers
        Container(
          color: const Color(0xFF0B0E14),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: const Row(
            children: [
              Expanded(child: Text("CALLS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 12))),
              Expanded(child: Text("STRIKE", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))),
              Expanded(child: Text("PUTS", textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 12))),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.white10),

        // Strike Scroll List
        Expanded(
          child: ListView.builder(
            itemCount: strikes.length,
            itemBuilder: (context, index) {
              int strike = strikes[index];
              double callP = _calculateCallPrice(indexData.spotPrice, strike);
              double putP = _calculatePutPrice(indexData.spotPrice, strike);

              bool isSpotHere = false;
              if (index < strikes.length - 1) {
                if (indexData.spotPrice >= strike && indexData.spotPrice < strikes[index + 1]) {
                  isSpotHere = true;
                }
              }

              return Column(
                children: [
                  if (isSpotHere)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        "SPOT: ${indexData.spotPrice.toStringAsFixed(2)} | ${indexData.change >= 0 ? '+' : ''}${indexData.change.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amberAccent),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: strike < indexData.spotPrice ? Colors.green.withOpacity(0.04) : Colors.red.withOpacity(0.04),
                      border: const Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
                    ),
                    child: Row(
                      children: [
                        // CALL
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _buyOption("${indexData.symbol} $strike CE", callP, indexData.lotSize),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("₹${callP.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                                const Text("CALL", style: TextStyle(color: Colors.grey, fontSize: 9)),
                              ],
                            ),
                          ),
                        ),
                        // STRIKE
                        Expanded(
                          child: Column(
                            children: [
                              Text("$strike", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                              Container(
                                height: 2,
                                width: 25,
                                color: strike < indexData.spotPrice ? Colors.green : Colors.red,
                              )
                            ],
                          ),
                        ),
                        // PUT
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _buyOption("${indexData.symbol} $strike PE", putP, indexData.lotSize),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("₹${putP.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                                const Text("PUT", style: TextStyle(color: Colors.grey, fontSize: 9)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class MarketWatchScreen extends StatefulWidget {
  final UserAccount user;
  final bool isMarketOpen;
  const MarketWatchScreen({super.key, required this.user, required this.isMarketOpen});

  @override
  State<MarketWatchScreen> createState() => _MarketWatchScreenState();
}

class _MarketWatchScreenState extends State<MarketWatchScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    List<IndexData> filteredIndices = globalIndices.values.where((s) {
      return s.symbol.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: "Search Index...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF151D2A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: filteredIndices.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white10),
            itemBuilder: (context, index) {
              final stock = filteredIndices[index];
              final isPos = stock.change >= 0;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text("NSE INDEX | Lot: ${stock.lotSize}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("₹${stock.spotPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isPos ? const Color(0xFF00C853) : Colors.redAccent)),
                    Text("${isPos ? '+' : ''}${stock.change.toStringAsFixed(2)}", style: TextStyle(fontSize: 11, color: isPos ? const Color(0xFF00C853) : Colors.redAccent)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PortfolioScreen extends StatelessWidget {
  final UserAccount user;
  const PortfolioScreen({super.key, required this.user});

  double _calculatePnL(PositionItem pos) {
    return 0.0;
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
