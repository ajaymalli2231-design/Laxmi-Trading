import 'dart:async';
import 'dart:convert';
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
      title: 'Laxmi Trading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9FAFC),
        primaryColor: const Color(0xFF00D09C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      home: const MainDashboard(),
    );
  }
}

// ---------------------------------------------------------------------------
// DATA MODELS & GLOBAL STATE
// ---------------------------------------------------------------------------
class UserAccount {
  String name;
  double balance;
  UserAccount({required this.name, this.balance = 100000.0});
}

UserAccount currentUser = UserAccount(name: "Ajay", balance: 100000.0);

class IndexData {
  final String symbol;
  final String tvSymbol;
  double spotPrice;
  double change;
  double changePercent;
  double todaysLow;
  double todaysHigh;

  IndexData({
    required this.symbol,
    required this.tvSymbol,
    required this.spotPrice,
    required this.change,
    required this.changePercent,
    required this.todaysLow,
    required this.todaysHigh,
  });
}

Map<String, IndexData> globalIndices = {
  "NIFTY 50": IndexData(
    symbol: "NIFTY 50",
    tvSymbol: "NSE:NIFTY",
    spotPrice: 23936.30,
    change: 62.85,
    changePercent: 0.26,
    todaysLow: 23850.10,
    todaysHigh: 24010.50,
  ),
  "Bse Sensex": IndexData(
    symbol: "Bse Sensex",
    tvSymbol: "BSE:SENSEX",
    spotPrice: 76655.49,
    change: 502.63,
    changePercent: 0.66,
    todaysLow: 76529.50,
    todaysHigh: 76883.14,
  ),
};

// ---------------------------------------------------------------------------
// MAIN DASHBOARD (GROWW LAYOUT)
// ---------------------------------------------------------------------------
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> bottomPages = [
      _buildExploreTabContent(context),
      const OptionChainScreen(),
      WalletScreen(user: currentUser, onBalanceChanged: () => setState(() {})),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF00D09C),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Text("Search Laxmi", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: _bottomNavIndex != 0
          ? bottomPages[_bottomNavIndex]
          : Column(
              children: [
                // Top Indices Bar (NIFTY & SENSEX)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _openStockDetail(context, globalIndices["NIFTY 50"]!),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("NIFTY 50", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Row(
                                children: [
                                  Text("${globalIndices["NIFTY 50"]!.spotPrice.toStringAsFixed(2)} ", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text("+${globalIndices["NIFTY 50"]!.change}", style: const TextStyle(fontSize: 11, color: Color(0xFF00D09C), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(height: 16, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 12)),
                      Expanded(
                        child: InkWell(
                          onTap: () => _openStockDetail(context, globalIndices["Bse Sensex"]!),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("SENSEX", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Row(
                                children: [
                                  Text("${globalIndices["Bse Sensex"]!.spotPrice.toStringAsFixed(2)} ", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text("+${globalIndices["Bse Sensex"]!.change}", style: const TextStyle(fontSize: 11, color: Color(0xFF00D09C), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

                // Top Navigation Tabs
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF00D09C),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    tabs: const [
                      Tab(text: "Explore"),
                      Tab(text: "Holdings"),
                      Tab(text: "Positions"),
                      Tab(text: "Orders"),
                    ],
                  ),
                ),

                // Tab Body
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildExploreTabContent(context),
                      const Center(child: Text("Holdings Empty")),
                      const Center(child: Text("No Open Positions")),
                      const Center(child: Text("No Pending Orders")),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (i) => setState(() => _bottomNavIndex = i),
        selectedItemColor: const Color(0xFF00D09C),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Stocks'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), label: 'F&O'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Pay'),
        ],
      ),
    );
  }

  Widget _buildExploreTabContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Recently viewed", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildRecentItem("GUJTLRM", "0.00%", Colors.grey, Colors.green.shade100, "G"),
              _buildRecentItem("CHANDRI...", "+4.96%", const Color(0xFF00D09C), Colors.red.shade100, "C"),
              _buildRecentItem("GTLINFRA", "+0.86%", const Color(0xFF00D09C), Colors.blue.shade100, "GTL"),
              _buildRecentItem("ADANIGRE...", "+1.22%", const Color(0xFF00D09C), Colors.amber.shade100, "adani"),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text("Most traded on Laxmi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _buildStockCard(context, "IFCI", "₹101.59", "+5.68 (5.92%)", true, "IFCI", "NSE:IFCI", 95.0, 105.0),
            _buildStockCard(context, "Skipper", "₹594.25", "+47.35 (8.66%)", true, "SKIPPER", "NSE:SKIPPER", 540.0, 610.0),
            _buildStockCard(context, "PC Jeweller", "₹11.52", "+1.00 (9.51%)", true, "PCJ", "NSE:PCJEWELLER", 10.0, 12.5),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("See more ", style: TextStyle(color: Color(0xFF00D09C), fontWeight: FontWeight.bold, fontSize: 16)),
                    Icon(Icons.arrow_forward_ios, color: Color(0xFF00D09C), size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentItem(String title, String change, Color changeColor, Color bgColor, String logoText) {
    return Container(
      width: 75,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(logoText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          ),
          const SizedBox(height: 6),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          Text(change, style: TextStyle(fontSize: 10, color: changeColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStockCard(BuildContext context, String title, String priceStr, String changeStr, bool isPositive, String logo, String symbol, double low, double high) {
    double priceVal = double.tryParse(priceStr.replaceAll('₹', '').replaceAll(',', '')) ?? 100.0;
    return InkWell(
      onTap: () {
        _openStockDetail(
          context,
          IndexData(
            symbol: title,
            tvSymbol: symbol,
            spotPrice: priceVal,
            change: 1.0,
            changePercent: 1.0,
            todaysLow: low,
            todaysHigh: high,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
              child: Text(logo, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(priceStr, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(changeStr, style: TextStyle(fontSize: 11, color: isPositive ? const Color(0xFF00D09C) : Colors.red, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _openStockDetail(BuildContext context, IndexData item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StockDetailScreen(item: item)),
    );
  }
}

// ---------------------------------------------------------------------------
// STOCK / INDEX DETAIL VIEW (LIVE CHART + PERFORMANCE BAR)
// ---------------------------------------------------------------------------
class StockDetailScreen extends StatefulWidget {
  final IndexData item;
  const StockDetailScreen({super.key, required this.item});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> with SingleTickerProviderStateMixin {
  late final WebViewController _webViewController;
  late TabController _tabController;

  String selectedTimeframe = "1D";
  bool isCandleView = false;
  final List<String> timeframes = ["1D", "1W", "1M", "3M", "6M", "1Y", "5Y", "All"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initWebView();
  }

  void _initWebView() {
    String chartStyle = isCandleView ? "1" : "3";
    String htmlContent = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
      <style>
        body, html { margin: 0; padding: 0; width: 100%; height: 100%; background-color: #FFFFFF; overflow: hidden; }
        #tradingview_widget { width: 100%; height: 100%; }
      </style>
    </head>
    <body>
      <div id="tradingview_widget"></div>
      <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
      <script type="text/javascript">
        new TradingView.widget({
          "autosize": true,
          "symbol": "${widget.item.tvSymbol}",
          "interval": "5",
          "timezone": "Asia/Kolkata",
          "theme": "light",
          "style": "$chartStyle",
          "locale": "en",
          "toolbar_bg": "#FFFFFF",
          "enable_publishing": false,
          "hide_top_toolbar": true,
          "hide_legend": true,
          "save_image": false,
          "container_id": "tradingview_widget"
        });
      </script>
    </body>
    </html>
    ''';

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..loadRequest(Uri.dataFromString(htmlContent, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')));
  }

  @override
  Widget build(BuildContext context) {
    double currentProgress = ((widget.item.spotPrice - widget.item.todaysLow) /
            (widget.item.todaysHigh - widget.item.todaysLow))
        .clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border, color: Colors.black87), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item.symbol, style: const TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(widget.item.spotPrice.toStringAsFixed(2), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text("+${widget.item.change.toStringAsFixed(2)} (${widget.item.changePercent.toStringAsFixed(2)}%)",
                              style: const TextStyle(fontSize: 13, color: Color(0xFF00D09C), fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          Text(selectedTimeframe, style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(height: 230, child: WebViewWidget(controller: _webViewController)),
                const SizedBox(height: 12),

                // Timeframe Filter Chips & Candlestick Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: timeframes.map((tf) {
                              bool isSelected = selectedTimeframe == tf;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: ChoiceChip(
                                  label: Text(tf, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.black87 : Colors.black54)),
                                  selected: isSelected,
                                  selectedColor: Colors.grey.shade200,
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: isSelected ? Colors.grey.shade400 : Colors.transparent),
                               onSelected: (bool selected) {
                                    if (selected) setState(() => selectedTimeframe = tf);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(isCandleView ? Icons.show_chart : Icons.candlestick_chart, color: const Color(0xFF00D09C), size: 22),
                        onPressed: () {
                          setState(() {
                            isCandleView = !isCandleView;
                            _initWebView();
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1, color: Color(0xFFF2F4F7)),

                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black87,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black87,
                  indicatorWeight: 2,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  tabs: const [Tab(text: "Overview"), Tab(text: "F&O"), Tab(text: "ETFs")],
                ),

                const SizedBox(height: 20),

                // Performance Section (Today's Low & High Bar)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text("Performance", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          SizedBox(width: 6),
                          Icon(Icons.info_outline, size: 16, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Today's Low", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(widget.item.todaysLow.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("Today's High", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(widget.item.todaysHigh.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(height: 4, width: double.infinity, decoration: BoxDecoration(color: const Color(0xFF00D09C), borderRadius: BorderRadius.circular(2))),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return Positioned(
                                left: (constraints.maxWidth * currentProgress) - 6,
                                child: const Icon(Icons.arrow_drop_up, size: 24, color: Colors.black87),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Fixed Action Buttons (Chart & Chain)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.candlestick_chart_outlined, color: Colors.black87, size: 20),
                      label: const Text("Chart", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
                      style: OutlinedButton.styleFrom(backgroundColor: const Color(0xFFF2F4F7), side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const OptionChainScreen()));
                      },
                      icon: const Icon(Icons.swap_calls_outlined, color: Colors.black87, size: 20),
                      label: const Text("Chain", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
                      style: OutlinedButton.styleFrom(backgroundColor: const Color(0xFFF2F4F7), side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ORDER BUY SCREEN (EXACT GROWW ORDER SHEET)
// ---------------------------------------------------------------------------
class OrderBuyScreen extends StatefulWidget {
  final String stockName;
  final double currentPrice;
  final int lotSize;
  final double userBalance;

  const OrderBuyScreen({
    super.key,
    required this.stockName,
    required this.currentPrice,
    this.lotSize = 65,
    required this.userBalance,
  });

  @override
  State<OrderBuyScreen> createState() => _OrderBuyScreenState();
}

class _OrderBuyScreenState extends State<OrderBuyScreen> {
  bool isDelivery = true;
  int quantity = 65;

  @override
  Widget build(BuildContext context) {
    double approxReq = quantity * widget.currentPrice;
    bool hasEnoughBalance = widget.userBalance >= approxReq;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.stockName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("₹${widget.currentPrice.toStringAsFixed(2)} (5.10%)", style: const TextStyle(fontSize: 12, color: Color(0xFF00D09C))),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text("Delivery"),
                        selected: isDelivery,
                        selectedColor: Colors.grey.shade200,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(color: isDelivery ? Colors.black : Colors.grey, fontWeight: FontWeight.bold),
                        onSelected: (val) => setState(() => isDelivery = true),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text("Intraday"),
                        selected: !isDelivery,
                        selectedColor: Colors.grey.shade200,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(color: !isDelivery ? Colors.black : Colors.grey, fontWeight: FontWeight.bold),
                        onSelected: (val) => setState(() => isDelivery = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Qty  1 lot x ${widget.lotSize}", style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () {
                                if (quantity > widget.lotSize) setState(() => quantity -= widget.lotSize);
                              },
                            ),
                            Text("$quantity", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () => setState(() => quantity += widget.lotSize),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Text("Price Market ", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                          Icon(Icons.unfold_more, size: 16, color: Colors.grey),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                        child: const Text("At Market", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Add stoploss/target", style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline, fontSize: 13)),
                  const Spacer(),
                  if (!hasEnoughBalance)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(8)),
                      child: const Text("Available balance is not enough.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF8D6E63), fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Balance : ₹${widget.userBalance.toStringAsFixed(0)}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      Row(
                        children: [
                          const Text("Approx req : ", style: TextStyle(fontSize: 13, color: Colors.grey)),
                          Text("₹${approxReq.toStringAsFixed(0)} ", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const Icon(Icons.refresh, size: 14, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: hasEnoughBalance ? () {} : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasEnoughBalance ? const Color(0xFF00D09C) : const Color(0xFFC8E6C9),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Buy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ),
                      if (!hasEnoughBalance) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D09C),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Add money", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Container(
            color: const Color(0xFFF2F4F7),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.2),
              itemBuilder: (context, index) {
                if (index == 9) return const SizedBox();
                if (index == 10) return _buildPadBtn("0");
                if (index == 11) return const Icon(Icons.backspace_outlined, size: 20, color: Colors.black87);
                return _buildPadBtn("${index + 1}");
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPadBtn(String txt) {
    return Center(child: Text(txt, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)));
  }
}

// ---------------------------------------------------------------------------
// OPTION CHAIN SCREEN
// ---------------------------------------------------------------------------
class OptionChainScreen extends StatelessWidget {
  const OptionChainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<int> strikes = [23800, 23850, 23900, 23950, 24000, 24050, 24100];
    return Scaffold(
      appBar: AppBar(title: const Text("Option Chain")),
      body: Column(
        children: [
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: const Row(
              children: [
                Expanded(child: Text("CALLS", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00D09C)))),
                Expanded(child: Text("STRIKE", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(child: Text("PUTS", textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: strikes.length,
              itemBuilder: (context, index) {
                int strike = strikes[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderBuyScreen(
                          stockName: "NIFTY $strike CE",
                          currentPrice: 102.05,
                          userBalance: currentUser.balance,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                    child: Row(
                      children: [
                        const Expanded(child: Text("₹120.50", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00D09C)))),
                        Expanded(child: Text("$strike", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                        const Expanded(child: Text("₹85.20", textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent))),
                      ],
                    ),
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

// ---------------------------------------------------------------------------
// WALLET / AUTO-REFILL SETTLEMENT SCREEN
// ---------------------------------------------------------------------------
class WalletScreen extends StatefulWidget {
  final UserAccount user;
  final VoidCallback onBalanceChanged;
  const WalletScreen({super.key, required this.user, required this.onBalanceChanged});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _amountController = TextEditingController();

  void _showAddMoneyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Add Money to Laxmi Balance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Enter Amount (₹)"),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    double? added = double.tryParse(_amountController.text);
                    if (added != null && added > 0) {
                      setState(() {
                        widget.user.balance += added;
                      });
                      widget.onBalanceChanged();
                      _amountController.clear();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D09C)),
                  child: const Text("ADD FUNDS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Laxmi Balance", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text("₹${widget.user.balance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text("Auto refill of Laxmi balance ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Icon(Icons.info_outline, size: 16, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Funds will be added automatically from bank account post periodic settlement on 4th September",
                          style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F8F5),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Setup", style: TextStyle(color: Color(0xFF00D09C), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8F8F5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Withdraw", style: TextStyle(color: Color(0xFF00D09C), fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _showAddMoneyModal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D09C),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Add money", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
