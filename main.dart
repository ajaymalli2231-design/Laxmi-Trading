
import 'package:flutter/material.dart';

void main() => runApp(const LaxmiTradingApp());

class LaxmiTradingApp extends StatelessWidget {
  const LaxmiTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Laxmi Trading',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        scaffoldBackgroundColor: const Color(0xfff5f7fa),
      ),
      home: const LoginPage(),
    );
  }
}

/*
  LAXMI TRADING - all-in-one prototype

  Includes:
  - Friend login with phone + OTP flow
  - Stock search
  - Indian indices
  - CALL / PUT option chain for NIFTY, BANK NIFTY, FINNIFTY and SENSEX
  - BUY / SELL
  - Portfolio + orders
  - Admin-only fund increase/decrease screen
  - User-specific balances inside this installed app

  IMPORTANT:
  A main.dart file alone cannot provide a truly private OTP or secure
  multi-device admin account. For a real shared app, OTP, users, balances
  and admin permissions must live on a secure backend. The admin PIN below
  is only a local prototype gate and must NOT be treated as production
  security.
*/

const String adminPin = '928371'; // Change for local testing.

class UserAccount {
  String phone;
  double balance;
  UserAccount(this.phone, this.balance);
}

final Map<String, UserAccount> demoUsers = {
  '9999999999': UserAccount('9999999999', 500000),
};

class Quote {
  final String symbol;
  final String name;
  final double price;
  final double change;
  const Quote(this.symbol, this.name, this.price, this.change);
}

const stocks = <Quote>[
  Quote('RELIANCE', 'Reliance Industries', 1450, 18.4),
  Quote('HDFCBANK', 'HDFC Bank', 1760.2, 12.1),
  Quote('ICICIBANK', 'ICICI Bank', 1325.5, 8.7),
  Quote('SBIN', 'State Bank of India', 820.4, 6.2),
  Quote('TCS', 'Tata Consultancy Services', 3120, -14.2),
  Quote('INFY', 'Infosys', 1542.3, 9.1),
  Quote('BHARTIARTL', 'Bharti Airtel', 1925.6, 22.4),
  Quote('ITC', 'ITC', 420.8, 2.1),
  Quote('LT', 'Larsen & Toubro', 3820.5, 35.2),
  Quote('AXISBANK', 'Axis Bank', 1190.4, -5.3),
  Quote('KOTAKBANK', 'Kotak Mahindra Bank', 1988, 4.8),
  Quote('MARUTI', 'Maruti Suzuki', 12650, 90),
  Quote('M&M', 'Mahindra & Mahindra', 3260.5, 41.3),
  Quote('TATAMOTORS', 'Tata Motors', 985.2, -8.1),
  Quote('TATASTEEL', 'Tata Steel', 178.4, 1.9),
  Quote('HINDALCO', 'Hindalco Industries', 720.6, 5.6),
  Quote('ADANIENT', 'Adani Enterprises', 2480, 26),
  Quote('ADANIPORTS', 'Adani Ports', 1410, 16.2),
  Quote('SUNPHARMA', 'Sun Pharmaceutical', 1788.2, 11.3),
  Quote('ONGC', 'ONGC', 295.8, 3.4),
  Quote('NTPC', 'NTPC', 402.2, 2.8),
  Quote('POWERGRID', 'Power Grid', 345.6, -1.2),
  Quote('COALINDIA', 'Coal India', 515.2, 4.4),
  Quote('BEL', 'Bharat Electronics', 385.7, 7.8),
  Quote('HAL', 'Hindustan Aeronautics', 5150, 62),
  Quote('WIPRO', 'Wipro', 610.4, 3.2),
  Quote('HCLTECH', 'HCL Technologies', 1640.5, 12),
  Quote('TECHM', 'Tech Mahindra', 1785, -7.5),
  Quote('ULTRACEMCO', 'UltraTech Cement', 12450, 55),
  Quote('ASIANPAINT', 'Asian Paints', 2875, -18),
  Quote('TITAN', 'Titan Company', 3850, 24),
  Quote('NESTLEIND', 'Nestle India', 2460, 8),
  Quote('HINDUNILVR', 'Hindustan Unilever', 2620, 13),
  Quote('BAJFINANCE', 'Bajaj Finance', 8650, 75),
  Quote('BAJAJFINSV', 'Bajaj Finserv', 2100, 18),
  Quote('EICHERMOT', 'Eicher Motors', 5650, 45),
  Quote('HEROMOTOCO', 'Hero MotoCorp', 5200, -22),
  Quote('CIPLA', 'Cipla', 1540, 9),
  Quote('DRREDDY', 'Dr Reddy Labs', 1280, -6),
  Quote('DIVISLAB', 'Divi’s Laboratories', 6250, 32),
  Quote('APOLLOHOSP', 'Apollo Hospitals', 7350, 70),
  Quote('TRENT', 'Trent', 7350, 80),
  Quote('ETERNAL', 'Eternal (Zomato)', 325, 4.2),
  Quote('IRCTC', 'IRCTC', 820, 5.1),
  Quote('DLF', 'DLF', 875, 7.4),
  Quote('SIEMENS', 'Siemens', 7100, 52),
  Quote('INDUSINDBK', 'IndusInd Bank', 925, -12),
  Quote('BANKBARODA', 'Bank of Baroda', 265, 3.1),
];

class IndexQuote {
  final String name;
  final double value;
  const IndexQuote(this.name, this.value);
}

const indices = <IndexQuote>[
  IndexQuote('NIFTY 50', 24341.15),
  IndexQuote('BANK NIFTY', 52231.20),
  IndexQuote('FINNIFTY', 23045.80),
  IndexQuote('SENSEX', 80245.10),
];

class Position {
  final String symbol;
  int qty;
  double avg;
  Position(this.symbol, this.qty, this.avg);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phone = TextEditingController();
  final otp = TextEditingController();
  bool sent = false;

  void sendOtp() {
    final p = phone.text.replaceAll(RegExp(r'\D'), '');
    if (p.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
      );
      return;
    }
    demoUsers.putIfAbsent(p, () => UserAccount(p, 500000));
    setState(() => sent = true);
  }

  void login() {
    if (otp.text.trim() != '123456') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP is not valid')),
      );
      return;
    }
    final p = phone.text.replaceAll(RegExp(r'\D'), '');
    final user = demoUsers[p]!;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TradingHome(user: user)),
    );
  }

  void openAdmin() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Private Admin Access'),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'Admin PIN',
            prefixIcon: Icon(Icons.admin_panel_settings),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          FilledButton(
            onPressed: () {
              if (controller.text == adminPin) {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wrong admin PIN')),
                );
              }
            },
            child: const Text('OPEN ADMIN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff07111f),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Column(
              children: [
                const Icon(Icons.account_balance, size: 76, color: Colors.amber),
                const SizedBox(height: 16),
                const Text(
                  'LAXMI TRADING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'INVEST • TRADE • GROW',
                  style: TextStyle(color: Colors.white70, letterSpacing: 1.3),
                ),
                const SizedBox(height: 42),
                TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: loginDec('Mobile Number', Icons.phone_android),
                ),
                if (sent) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: otp,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(color: Colors.white),
                    decoration: loginDec('Enter OTP', Icons.lock_outline),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: sent ? login : sendOtp,
                    child: Text(sent ? 'VERIFY & LOGIN' : 'SEND OTP'),
                  ),
                ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: openAdmin,
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Private Admin'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Secure real OTP and shared accounts require a server/backend.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration loginDec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      );
}

class TradingHome extends StatefulWidget {
  final UserAccount user;
  const TradingHome({super.key, required this.user});

  @override State<TradingHome> createState() => _TradingHomeState();
}

class _TradingHomeState extends State<TradingHome> {
  int tab = 0;
  final Map<String, Position> positions = {};
  final List<String> orders = [];

  double get cash => widget.user.balance;
  set cash(double v) => widget.user.balance = v;

  void stockTrade(Quote q, bool buy) {
    if (buy && cash < q.price) {
      snack('Insufficient funds');
      return;
    }
    setState(() {
      if (buy) {
        final p = positions[q.symbol];
        if (p == null) {
          positions[q.symbol] = Position(q.symbol, 1, q.price);
        } else {
          p.avg = ((p.avg * p.qty) + q.price) / (p.qty + 1);
          p.qty++;
        }
        cash -= q.price;
        orders.insert(0, 'BUY ${q.symbol} 1 @ ₹${q.price.toStringAsFixed(2)}');
      } else {
        final p = positions[q.symbol];
        if (p == null || p.qty <= 0) {
          snack('No position to sell');
          return;
        }
        p.qty--;
        cash += q.price;
        orders.insert(0, 'SELL ${q.symbol} 1 @ ₹${q.price.toStringAsFixed(2)}');
        if (p.qty == 0) positions.remove(q.symbol);
      }
    });
  }

  void optionTrade(
    String underlying,
    String side,
    int strike,
    String type,
    double premium,
    int lot,
  ) {
    final amount = premium * lot;
    if (side == 'BUY' && cash < amount) {
      snack('Insufficient funds');
      return;
    }
    setState(() {
      if (side == 'BUY') {
        cash -= amount;
      } else {
        cash += amount;
      }
      orders.insert(
        0,
        '$side $underlying ${strike.toString()} $type '
        '1 LOT @ ₹${premium.toStringAsFixed(2)}',
      );
    });
    snack('$side order placed');
  }

  void snack(String text) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text)),
      );

  @override
  Widget build(BuildContext context) {
    final pages = [
      homeTab(),
      portfolioTab(),
      ordersTab(),
      profileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('LAXMI TRADING', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: () => showStockSearch(),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'Portfolio'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget homeTab() => ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    child: Icon(Icons.account_balance_wallet),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available Balance', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('Trading Fund', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text(
                    '₹${cash.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: showStockSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Stocks'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showOptionChain('NIFTY 50'),
                  icon: const Icon(Icons.show_chart),
                  label: const Text('Options'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text('Indian Indices', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...indices.map(
            (i) => Card(
              child: ListTile(
                onTap: () => showOptionChain(i.name),
                leading: const CircleAvatar(child: Icon(Icons.trending_up)),
                title: Text(i.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(i.value.toStringAsFixed(2)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('+0.26%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Text('CALL / PUT', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Popular Stocks', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          ...stocks.take(10).map(stockCard),
        ],
      );

  Widget stockCard(Quote q) => Card(
        child: ListTile(
          onTap: () => showStockTrade(q),
          title: Text(q.symbol, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text('${q.name}\n₹${q.price.toStringAsFixed(2)}'),
          isThreeLine: true,
          trailing: Text(
            '${q.change >= 0 ? '+' : ''}${q.change.toStringAsFixed(2)}',
            style: TextStyle(
              color: q.change >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  void showStockSearch() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final text = controller.text.toUpperCase();
          final result = stocks
              .where((s) =>
                  s.symbol.contains(text) ||
                  s.name.toUpperCase().contains(text))
              .toList();

          return SizedBox(
            height: MediaQuery.of(ctx).size.height * .88,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Search Stocks', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                      ),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                    ],
                  ),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    onChanged: (_) => setSheet(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Company or symbol',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: result.map(stockCard).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void showStockTrade(Quote q) => showModalBottomSheet(
        context: context,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(q.symbol, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
              Text(q.name),
              const SizedBox(height: 5),
              Text('₹${q.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        stockTrade(q, true);
                      },
                      child: const Text('BUY'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                        stockTrade(q, false);
                      },
                      child: const Text('SELL'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  void showOptionChain(String underlying) {
    final isSensex = underlying == 'SENSEX';
    final step = isSensex ? 100 : 100;
    final center = isSensex ? 80200 : 24300;
    final lot = isSensex ? 20 : (underlying == 'BANK NIFTY' ? 30 : 65);
    final strikes = List<int>.generate(9, (i) => center - (4 - i) * step);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * .92,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('$underlying OPTIONS', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Expiry: 30 Sep 2026   •   Lot Size: $lot',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: const Row(
                  children: [
                    Expanded(child: Text('CALL', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('STRIKE', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('PUT', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: strikes.map((s) {
                    final distance = (center - s).abs();
                    final call = 115.0 + distance * .38;
                    final put = 105.0 + distance * .34;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 3),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text('₹${call.toStringAsFixed(2)}'),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 3,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          optionTrade(underlying, 'BUY', s, 'CE', call, lot);
                                        },
                                        child: const Text('BUY CE'),
                                      ),
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          optionTrade(underlying, 'SELL', s, 'CE', call, lot);
                                        },
                                        child: const Text('SELL CE'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  '$s',
                                  style: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text('₹${put.toStringAsFixed(2)}'),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 3,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          optionTrade(underlying, 'BUY', s, 'PE', put, lot);
                                        },
                                        child: const Text('BUY PE'),
                                      ),
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          optionTrade(underlying, 'SELL', s, 'PE', put, lot);
                                        },
                                        child: const Text('SELL PE'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget portfolioTab() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Available Cash  ₹${cash.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          const Text('Positions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          if (positions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('No open positions yet.'),
            ),
          ...positions.values.map(
            (p) => Card(
              child: ListTile(
                title: Text(p.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Qty ${p.qty}  •  Avg ₹${p.avg.toStringAsFixed(2)}'),
              ),
            ),
          ),
        ],
      );

  Widget ordersTab() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Order History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (orders.isEmpty) const Text('No orders yet.'),
          ...orders.map(
            (o) => Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text(o),
                subtitle: const Text('Completed'),
              ),
            ),
          ),
        ],
      );

  Widget profileTab() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),
          const CircleAvatar(radius: 38, child: Icon(Icons.person, size: 42)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Laxmi Trading User',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Mobile'),
              trailing: Text(widget.user.phone),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Balance'),
              trailing: Text('₹${cash.toStringAsFixed(2)}'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Admin controls'),
              subtitle: const Text('Available only from Private Admin'),
            ),
          ),
        ],
      );
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String? selectedPhone;

  UserAccount? get selected =>
      selectedPhone == null ? null : demoUsers[selectedPhone!];

  void addUser() {
    final phone = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Friend Account'),
        content: TextField(
          controller: phone,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: const InputDecoration(
            labelText: 'Friend mobile number',
            prefixIcon: Icon(Icons.phone),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          FilledButton(
            onPressed: () {
              final p = phone.text.replaceAll(RegExp(r'\D'), '');
              if (p.length == 10) {
                setState(() {
                  demoUsers.putIfAbsent(p, () => UserAccount(p, 500000));
                  selectedPhone = p;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }

  void changeFund(double amount) {
    final u = selected;
    if (u == null) return;
    setState(() {
      u.balance += amount;
      if (u.balance < 0) u.balance = 0;
    });
  }

  void setExactBalance() {
    final u = selected;
    if (u == null) return;
    final controller = TextEditingController(text: u.balance.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Exact Fund'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'New balance',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.replaceAll(',', ''));
              if (value != null && value >= 0) {
                setState(() => u.balance = value);
                Navigator.pop(ctx);
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = demoUsers.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Private Admin'),
        actions: [
          IconButton(onPressed: addUser, icon: const Icon(Icons.person_add)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 27,
                    child: Icon(Icons.admin_panel_settings),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Owner / Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text('Only this local admin screen can change funds.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Friend Accounts', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...users.map(
            (u) => Card(
              child: ListTile(
                selected: selectedPhone == u.phone,
                onTap: () => setState(() => selectedPhone = u.phone),
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(u.phone),
                subtitle: Text('₹${u.balance.toStringAsFixed(2)}'),
                trailing: selectedPhone == u.phone
                    ? const Icon(Icons.check_circle)
                    : null,
              ),
            ),
          ),
          if (selected != null) ...[
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Selected: ${selected!.phone}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      '₹${selected!.balance.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () => changeFund(10000),
                          icon: const Icon(Icons.add),
                          label: const Text('+ ₹10,000'),
                        ),
                        FilledButton.icon(
                          onPressed: () => changeFund(100000),
                          icon: const Icon(Icons.add),
                          label: const Text('+ ₹1 Lakh'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => changeFund(-10000),
                          icon: const Icon(Icons.remove),
                          label: const Text('- ₹10,000'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => changeFund(-100000),
                          icon: const Icon(Icons.remove),
                          label: const Text('- ₹1 Lakh'),
                        ),
                        TextButton.icon(
                          onPressed: setExactBalance,
                          icon: const Icon(Icons.edit),
                          label: const Text('Set exact amount'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Any amount can be entered in Set exact amount.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.logout),
            label: const Text('EXIT ADMIN'),
          ),
        ],
      ),
    );
  }
}
