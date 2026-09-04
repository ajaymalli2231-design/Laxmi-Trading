import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  final String tvSymbol; // TradingView Symbol
  double spotPrice;
  double change;
  final int minStrike;
  final int maxStrike;
  final int step;
  final int lotSize;

  IndexData({
    required this.symbol,
    required this.tvSymbol,
    required this.spotPrice,
    required this.change,
    required this.minStrike,
    required this.maxStrike,
    required this.step,
    required this.lotSize,
  });
}

Map<String, IndexData> globalIndices = {
  "NIFTY 50": IndexData(symbol: "NIFTY 50", tvSymbol: "NSE:NIFTY", spotPrice: 23873.45, change: -41.00, minStrike: 22100, maxStrike: 26400, step: 50, lotSize: 50),
  "BANKNIFTY": IndexData(symbol: "BANKNIFTY", tvSymbol: "NSE:BANKNIFTY", spotPrice: 48933.69, change: -131.61, minStrike: 43500, maxStrike: 69000, step: 100, lotSize: 15),
  "SENSEX": IndexData(symbol: "SENSEX", tvSymbol: "BSE:SENSEX", spotPrice: 78500.20, change: 120.50, minStrike: 69100, maxStrike: 86000, step: 100, lotSize: 10),
  "FINNIFTY": IndexData(symbol: "FINNIFTY", tvSymbol: "NSE:FINNIFTY", spotPrice: 21450.10, change: 15.30, minStrike: 20000, maxStrike: 23500, step: 50, lotSize: 40),
  "MIDCPNIFTY": IndexData(symbol: "MIDCPNIFTY", tvSymbol: "NSE:MIDCPNIFTY", spotPrice: 12300.80, change: -22.10, minStrike: 11000, maxStrike: 13500, step: 25, lotSize: 75),
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
            const Text('Pro Trading Engine with TradingView', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
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
            double tick = (_rnd.nextDouble() * 3.0 - 1.5);
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

// TRADINGVIEW LIVE CANDLESTICK CHART SCREEN
class TradingViewChartScreen extends StatefulWidget {
  final String symbol;
  final String tvSymbol;

  const TradingViewChartScreen({super.key, required this.symbol, required this.tvSymbol});

  @override
  State<TradingViewChartScreen> createState() => _TradingViewChartScreenState();
}

class _TradingViewChartScreenState extends State<TradingViewChartScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    
    // TradingView Widget HTML Code
    final String htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body, html { margin: 0; padding: 0; height: 100%; width: 100%; background-color: #0d1117; }
        #tradingview_widget { height: 100%; width: 100%; }
      </style>
    </head>
    <body>
      <div id="tradingview_widget"></div>
      <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
      <script type="text/javascript">
        new TradingView.widget({
          "autosize": true,
          "symbol": "${widget.tvSymbol}",
          "interval": "5",
          "timezone": "Asia/Kolkata",
          "theme": "dark",
          "style": "1",
          "locale": "in",
          "toolbar_bg": "#f1f3f6",
          "enable_publishing": false,
          "hide_side_toolbar": false,
          "allow_symbol_change": true,
          "container_id": "tradingview_widget"
        });
      </script>
    </body>
    </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0D1117))
      ..loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.symbol} Live Chart', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          )
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

// WATCHLIST SCREEN
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TradingViewChartScreen(
                        symbol: stock.symbol,
                        tvSymbol: stock.tvSymbol,
                      ),
                    ),
                  );
                },
                title: Row(
                  children: [
                    Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 6),
                    const Icon(Icons.show_chart, size: 18, color: Colors.blueAccent),
                  ],
                ),
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

// REALISTIC OPTION CHAIN SCREEN WITH CHART BUTTON
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

  double _getCallPrice(double spot, int strike) {
    double distance = (spot - strike);
    if (distance > 0) {
      return (distance * 0.85) + 40.0 + (spot * 0.001);
    } else {
      double otmDist = (strike - spot);
      double price = 120.0 * exp(-otmDist / 220.0);
      return max(0.15, price);
    }
  }

  double _getPutPrice(double spot, int strike) {
    double distance = (strike - spot);
    if (distance > 0) {
      return (distance * 0.85) + 40.0 + (spot * 0.001);
    } else {
      double otmDist = (spot - strike);
      double price = 120.0 * exp(-otmDist / 220.0);
      return max(0.15, price);
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
        
        // Index Selector Header with Chart Icon
        Container(
          color: const Color(0xFF151D2A),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  IconButton(
                    icon: const Icon(Icons.candlestick_chart, color: Colors.greenAccent),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TradingViewChartScreen(
                            symbol: indexData.symbol,
                            tvSymbol: indexData.tvSymbol,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("₹${indexData.spotPrice.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: indexData.change >= 0 ? Colors.greenAccent : Colors.redAccent)),
                  Text("${indexData.change >= 0 ? '+' : ''}${indexData.change.toStringAsFixed(2)} (${(indexData.change / indexData.spotPrice * 100).toStringAsFixed(2)}%)", style: TextStyle(fontSize: 11, color: indexData.change >= 0 ? Colors.greenAccent : Colors.redAccent)),
                ],
              )
            ],
          ),
        ),

        // Chain Titles
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
              double callP = _getCallPrice(indexData.spotPrice, strike);
              double putP = _getPutPrice(indexData.spotPrice, strike);

              bool isSpotHere = false;
              if (index < strikes.length - 1) {
                if (indexData.spotPrice >= strike && indexData.spotPrice < strikes[index + 1]) {
                  isSpotHere = true;
                }
              }

              double callChg = ((strike % 7) - 3.5);
              double putChg = ((strike % 5) - 2.5);

              return Column(
                children: [
                  if (isSpotHere)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber, width: 1),
                      ),
                      child: Text(
                        "${indexData.spotPrice.toStringAsFixed(2)} | ${indexData.change >= 0 ? '+' : ''}${indexData.change.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amberAccent),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: strike < indexData.spotPrice ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
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
                                Text("${callChg >= 0 ? '+' : ''}${callChg.toStringAsFixed(2)}%", style: TextStyle(color: callChg >= 0 ? Colors.greenAccent : Colors.redAccent, fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                        // STRIKE
                        Expanded(
                          child: Column(
                            children: [
                              Text("$strike", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                              Container(height: 2, width: 25, color: strike < indexData.spotPrice ? Colors.green : Colors.red)
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
                                Text("${putChg >= 0 ? '+' : ''}${putChg.toStringAsFixed(2)}%", style: TextStyle(color: putChg >= 0 ? Colors.greenAccent : Colors.redAccent, fontSize: 10)),
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

class PortfolioScreen extends StatelessWidget {
  final UserAccount user;
  const PortfolioScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Positions & Portfolio Screen", style: TextStyle(color: Colors.grey)));
  }
}

class WalletScreen extends StatelessWidget {
  final UserAccount user;
  const WalletScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Wallet Screen", style: TextStyle(color: Colors.grey)));
  }
}

class AdminPanelScreen extends StatelessWidget {
  final UserAccount adminUser;
  const AdminPanelScreen({super.key, required this.adminUser});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Admin Panel", style: TextStyle(color: Colors.grey)));
  }
}
