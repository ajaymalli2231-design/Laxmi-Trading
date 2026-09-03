import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const LaxmiTradingApp());

class LaxmiTradingApp extends StatelessWidget {
  const LaxmiTradingApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Laxmi Trading',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
          scaffoldBackgroundColor: const Color(0xfff7f8f2),
          appBarTheme: const AppBarTheme(backgroundColor: Color(0xfff7f8f2)),
          cardTheme: CardThemeData(elevation: 1, margin: const EdgeInsets.only(bottom: 12)),
        ),
        home: const LoginPage(),
      );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final phone = TextEditingController();
  final otp = TextEditingController();
  bool sent = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xff07111f),
    body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(28), child: Column(children: [
      const Icon(Icons.account_balance, size: 72, color: Colors.amber),
      const SizedBox(height: 16),
      const Text('LAXMI TRADING', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('INVEST • TRADE • GROW', style: TextStyle(color: Colors.white70, letterSpacing: 1.2)),
      const SizedBox(height: 42),
      TextField(controller: phone, keyboardType: TextInputType.phone, style: const TextStyle(color: Colors.white), decoration: _dec('Mobile Number', Icons.phone)),
      if (sent) ...[
        const SizedBox(height: 14),
        TextField(controller: otp, keyboardType: TextInputType.number, maxLength: 6, style: const TextStyle(color: Colors.white), decoration: _dec('Enter OTP', Icons.lock)),
      ],
      const SizedBox(height: 18),
      SizedBox(width: double.infinity, child: FilledButton(
        onPressed: () {
          if (!sent) setState(() => sent = true);
          else if (otp.text == '123456') Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
          else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Use OTP 123456 for this test build')));
        },
        child: Text(sent ? 'VERIFY & LOGIN' : 'SEND OTP'),
      )),
    ]))),
  );
  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label, prefixIcon: Icon(icon), labelStyle: const TextStyle(color: Colors.white70),
    filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );
}

class Quote {
  final String symbol, name;
  final double price, change;
  const Quote(this.symbol, this.name, this.price, this.change);
}

const stocks = <Quote>[
  Quote('RELIANCE', 'Reliance Industries', 1450.00, 18.40), Quote('HDFCBANK', 'HDFC Bank', 1760.20, 12.10),
  Quote('ICICIBANK', 'ICICI Bank', 1325.50, 8.70), Quote('SBIN', 'State Bank of India', 820.40, 6.20),
  Quote('TCS', 'Tata Consultancy Services', 3120.00, -14.20), Quote('INFY', 'Infosys', 1542.30, 9.10),
  Quote('BHARTIARTL', 'Bharti Airtel', 1925.60, 22.40), Quote('ITC', 'ITC', 420.80, 2.10),
  Quote('LT', 'Larsen & Toubro', 3820.50, 35.20), Quote('AXISBANK', 'Axis Bank', 1190.40, -5.30),
  Quote('KOTAKBANK', 'Kotak Mahindra Bank', 1988.00, 4.80), Quote('MARUTI', 'Maruti Suzuki', 12650.00, 90.00),
  Quote('M&M', 'Mahindra & Mahindra', 3260.50, 41.30), Quote('TATAMOTORS', 'Tata Motors', 985.20, -8.10),
  Quote('TATASTEEL', 'Tata Steel', 178.40, 1.90), Quote('HINDALCO', 'Hindalco Industries', 720.60, 5.60),
  Quote('ADANIENT', 'Adani Enterprises', 2480.00, 26.00), Quote('ADANIPORTS', 'Adani Ports', 1410.00, 16.20),
  Quote('SUNPHARMA', 'Sun Pharmaceutical', 1788.20, 11.30), Quote('ONGC', 'ONGC', 295.80, 3.40),
  Quote('NTPC', 'NTPC', 402.20, 2.80), Quote('POWERGRID', 'Power Grid', 345.60, -1.20),
  Quote('COALINDIA', 'Coal India', 515.20, 4.40), Quote('BEL', 'Bharat Electronics', 385.70, 7.80),
  Quote('HAL', 'Hindustan Aeronautics', 5150.00, 62.00), Quote('WIPRO', 'Wipro', 610.40, 3.20),
  Quote('HCLTECH', 'HCL Technologies', 1640.50, 12.00), Quote('TECHM', 'Tech Mahindra', 1785.00, -7.50),
  Quote('ULTRACEMCO', 'UltraTech Cement', 12450.00, 55.00), Quote('ASIANPAINT', 'Asian Paints', 2875.00, -18.00),
  Quote('TITAN', 'Titan Company', 3850.00, 24.00), Quote('NESTLEIND', 'Nestle India', 2460.00, 8.00),
  Quote('HINDUNILVR', 'Hindustan Unilever', 2620.00, 13.00), Quote('BAJFINANCE', 'Bajaj Finance', 8650.00, 75.00),
  Quote('BAJAJFINSV', 'Bajaj Finserv', 2100.00, 18.00), Quote('EICHERMOT', 'Eicher Motors', 5650.00, 45.00),
  Quote('HEROMOTOCO', 'Hero MotoCorp', 5200.00, -22.00), Quote('CIPLA', 'Cipla', 1540.00, 9.00),
  Quote('DRREDDY', 'Dr Reddy Labs', 1280.00, -6.00), Quote('DIVISLAB', 'Divi’s Laboratories', 6250.00, 32.00),
  Quote('APOLLOHOSP', 'Apollo Hospitals', 7350.00, 70.00), Quote('TRENT', 'Trent', 7350.00, 80.00),
  Quote('ZOMATO', 'Eternal (Zomato)', 325.00, 4.20), Quote('IRCTC', 'IRCTC', 820.00, 5.10),
  Quote('DLF', 'DLF', 875.00, 7.40), Quote('SIEMENS', 'Siemens', 7100.00, 52.00),
  Quote('INDUSINDBK', 'IndusInd Bank', 925.00, -12.00), Quote('BANKBARODA', 'Bank of Baroda', 265.00, 3.10),
];

class IndexQuote {
  final String name; final double value, change;
  const IndexQuote(this.name, this.value, this.change);
}
const indices = [
  IndexQuote('NIFTY 50', 24341.15, 0.26), IndexQuote('BANK NIFTY', 52231.20, 0.34),
  IndexQuote('FINNIFTY', 23045.80, 0.36), IndexQuote('SENSEX', 80245.10, 0.25),
];

class Position { String symbol; int qty; double avg; Position(this.symbol, this.qty, this.avg); }

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  int tab = 0;
  double cash = 500000;
  final Map<String, Position> positions = {};
  final List<String> orders = [];
  final List<double> marketHistory = [24210, 24255, 24180, 24305, 24270, 24360, 24310, 24395, 24341];

  void stockTrade(Quote q, bool buy) {
    if (buy && cash < q.price) { snack('Insufficient funds'); return; }
    setState(() {
      if (buy) {
        final p = positions[q.symbol];
        if (p == null) positions[q.symbol] = Position(q.symbol, 1, q.price);
        else { p.avg = ((p.avg * p.qty) + q.price) / (p.qty + 1); p.qty++; }
        cash -= q.price; orders.insert(0, 'BUY ${q.symbol} 1 @ ₹${q.price.toStringAsFixed(2)}');
      } else {
        final p = positions[q.symbol];
        if (p == null || p.qty <= 0) { snack('No position to sell'); return; }
        p.qty--; cash += q.price; orders.insert(0, 'SELL ${q.symbol} 1 @ ₹${q.price.toStringAsFixed(2)}');
        if (p.qty == 0) positions.remove(q.symbol);
      }
    });
  }

  void optionTrade(String side, String underlying, String strike, String type, double premium, int lot) {
    final amount = premium * lot;
    if (side == 'BUY' && cash < amount) { snack('Insufficient funds'); return; }
    setState(() {
      if (side == 'BUY') cash -= amount; else cash += amount;
      orders.insert(0, '$side $underlying $strike $type 1 LOT @ ₹${premium.toStringAsFixed(2)}');
    });
    snack('$side order placed');
  }

  void changeFunds() {
    final controller = TextEditingController();
    bool add = true;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialog) => AlertDialog(
      title: const Text('Fund Management'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        SegmentedButton<bool>(segments: const [ButtonSegment(value: true, label: Text('ADD FUNDS')), ButtonSegment(value: false, label: Text('REDUCE'))], selected: {add}, onSelectionChanged: (v) => setDialog(() => add = v.first)),
        const SizedBox(height: 16),
        TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Amount', border: OutlineInputBorder())),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')), FilledButton(onPressed: () {
        final amount = double.tryParse(controller.text) ?? 0;
        if (amount <= 0) return;
        if (!add && amount > cash) { snack('Amount is greater than available balance'); return; }
        setState(() => cash += add ? amount : -amount);
        orders.insert(0, '${add ? 'FUND ADDED' : 'FUND REDUCED'} ₹${amount.toStringAsFixed(2)}');
        Navigator.pop(ctx);
      }, child: Text(add ? 'ADD' : 'REDUCE'))],
    )));
  }

  void snack(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  @override
  Widget build(BuildContext context) {
    final pages = [homeTab(), portfolioTab(), ordersTab(), profileTab()];
    return Scaffold(
      appBar: AppBar(title: const Text('LAXMI TRADING', style: TextStyle(fontWeight: FontWeight.w800)), actions: [IconButton(onPressed: showStockSearch, icon: const Icon(Icons.search)), IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))]),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'Portfolio'),
        NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Orders'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
      ]),
    );
  }

  Widget homeTab() => ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
    Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
      CircleAvatar(radius: 28, backgroundColor: Colors.green.shade100, child: const Icon(Icons.account_balance_wallet, color: Colors.green, size: 30)),
      const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Available Balance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), Text('₹${cash.toStringAsFixed(2)}', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), const Text('Trading Fund', style: TextStyle(color: Colors.grey))])),
      IconButton(onPressed: changeFunds, icon: const Icon(Icons.edit_note, size: 30)),
    ]))),
    const SizedBox(height: 4),
    Card(child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Expanded(child: Text('NIFTY 50', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))), Text('24,341.15', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(width: 8), const Text('+0.26%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]),
      const SizedBox(height: 8), SizedBox(height: 125, child: CustomPaint(painter: MarketChartPainter(marketHistory, Colors.green))),
      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('09:15'), Text('11:00'), Text('13:00'), Text('15:30')]),
    ]))),
    const SizedBox(height: 8),
    Row(children: [
      Expanded(child: FilledButton.icon(onPressed: showStockSearch, icon: const Icon(Icons.search), label: const Text('Stocks'))),
      const SizedBox(width: 10),
      Expanded(child: OutlinedButton.icon(onPressed: () => showOptionChain('NIFTY 50'), icon: const Icon(Icons.show_chart), label: const Text('Options'))),
    ]),
    const SizedBox(height: 20),
    const Text('Indian Indices', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
    const SizedBox(height: 6),
    ...indices.map((i) => Card(child: ListTile(
      onTap: () => showIndexDetail(i),
      leading: CircleAvatar(backgroundColor: Colors.green.shade100, child: const Icon(Icons.trending_up, color: Colors.green)),
      title: Text(i.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(i.value.toStringAsFixed(2)),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text('+${i.change.toStringAsFixed(2)}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), const Text('CHART • OPTIONS', style: TextStyle(fontSize: 10, color: Colors.grey))]),
    ))),
    const SizedBox(height: 14),
    const Text('Popular Stocks', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
    ...stocks.take(8).map(stockCard),
  ]);

  Widget stockCard(Quote q) => Card(child: ListTile(
    onTap: () => showStockTrade(q), leading: const CircleAvatar(child: Icon(Icons.show_chart)),
    title: Text(q.symbol, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${q.name}\n₹${q.price.toStringAsFixed(2)}'), isThreeLine: true,
    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text('₹${q.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)), Text('${q.change >= 0 ? '+' : ''}${q.change.toStringAsFixed(2)}', style: TextStyle(color: q.change >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold))]),
  ));

  void showIndexDetail(IndexQuote i) => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => SizedBox(height: MediaQuery.of(context).size.height * .72, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Expanded(child: Text(i.name, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))]),
    Text(i.value.toStringAsFixed(2), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)), Text('+${i.change.toStringAsFixed(2)}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
    const SizedBox(height: 18), Expanded(child: CustomPaint(painter: MarketChartPainter(marketHistory.map((x) => x + (i.value - 24341.15)).toList(), Colors.green), child: const SizedBox.expand())),
    const SizedBox(height: 18), FilledButton.icon(onPressed: () { Navigator.pop(context); showOptionChain(i.name == 'SENSEX' ? 'SENSEX' : i.name); }, icon: const Icon(Icons.show_chart), label: const Text('OPEN CALL / PUT OPTIONS')),
  ])));

  void showStockSearch() {
    final controller = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => StatefulBuilder(builder: (ctx, setSheet) {
      final text = controller.text.toUpperCase();
      final result = stocks.where((s) => s.symbol.contains(text) || s.name.toUpperCase().contains(text)).toList();
      return SizedBox(height: MediaQuery.of(ctx).size.height * .88, child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Row(children: [const Expanded(child: Text('Search Stocks', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close))]),
        TextField(controller: controller, autofocus: true, onChanged: (_) => setSheet(() {}), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search company or symbol', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
        const SizedBox(height: 10), Expanded(child: ListView(children: result.map(stockCard).toList())),
      ])));
    }));
  }

  void showStockTrade(Quote q) => showModalBottomSheet(context: context, builder: (_) => Padding(padding: const EdgeInsets.all(22), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Row(children: [const Icon(Icons.show_chart), const SizedBox(width: 8), Text(q.symbol, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold))]), Text(q.name), Text('₹${q.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20)),
    const SizedBox(height: 12), SizedBox(height: 120, child: CustomPaint(painter: MarketChartPainter([q.price - q.change * 2, q.price - q.change, q.price - q.change * .3, q.price + q.change * .2, q.price], q.change >= 0 ? Colors.green : Colors.red))),
    const SizedBox(height: 14), Row(children: [Expanded(child: FilledButton(onPressed: () { Navigator.pop(context); stockTrade(q, true); }, child: const Text('BUY'))), const SizedBox(width: 12), Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () { Navigator.pop(context); stockTrade(q, false); }, child: const Text('SELL')))]),
  ]));

  void showOptionChain(String underlying) {
    final isSensex = underlying == 'SENSEX';
    final center = isSensex ? 80200 : (underlying == 'BANK NIFTY' ? 52200 : underlying == 'FINNIFTY' ? 23000 : 24300);
    final step = isSensex ? 100 : 100;
    final start = isSensex ? 79800 : (center - 400);
    final strikes = List.generate(9, (k) => start + k * step);
    final lot = isSensex ? 20 : underlying == 'BANK NIFTY' ? 30 : underlying == 'FINNIFTY' ? 40 : 75;
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => SizedBox(height: MediaQuery.of(context).size.height * .92, child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [
      Row(children: [Expanded(child: Text('$underlying OPTIONS', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))]),
      Align(alignment: Alignment.centerLeft, child: Text('Expiry: 30 Sep 2026  •  Lot Size: $lot', style: const TextStyle(fontWeight: FontWeight.w600))),
      const SizedBox(height: 8),
      Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Theme.of(context).colorScheme.surfaceContainerHighest), child: const Row(children: [Expanded(child: Text('CALL', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))), Expanded(child: Text('STRIKE', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))), Expanded(child: Text('PUT', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))])),
      Expanded(child: ListView(children: strikes.map((s) {
        final distance = (center - s).abs(); final call = 120.0 + distance * .35; final put = 110.0 + distance * .32;
        return Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
          Expanded(child: Column(children: [Text('₹${call.toStringAsFixed(2)}'), const SizedBox(height: 3), Wrap(spacing: 3, children: [OutlinedButton(onPressed: () { Navigator.pop(context); optionTrade('BUY', underlying, s.toString(), 'CE', call, lot); }, child: const Text('BUY CE')), OutlinedButton(onPressed: () { Navigator.pop(context); optionTrade('SELL', underlying, s.toString(), 'CE', call, lot); }, child: const Text('SELL CE'))])])),
          Expanded(child: Center(child: Text(s.toString(), style: const TextStyle(fontWeight: FontWeight.bold)))),
          Expanded(child: Column(children: [Text('₹${put.toStringAsFixed(2)}'), const SizedBox(height: 3), Wrap(spacing: 3, children: [OutlinedButton(onPressed: () { Navigator.pop(context); optionTrade('BUY', underlying, s.toString(), 'PE', put, lot); }, child: const Text('BUY PE')), OutlinedButton(onPressed: () { Navigator.pop(context); optionTrade('SELL', underlying, s.toString(), 'PE', put, lot); }, child: const Text('SELL PE'))])])),
        ])));
      }).toList())),
    ]))));
  }

  Widget portfolioTab() => ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: ListTile(leading: const Icon(Icons.account_balance_wallet), title: const Text('Available Cash'), trailing: Text('₹${cash.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)))),
    Card(child: ListTile(leading: const Icon(Icons.tune), title: const Text('Fund Management'), subtitle: const Text('Increase or reduce available fund'), onTap: changeFunds)),
    const SizedBox(height: 8), const Text('Positions', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
    if (positions.isEmpty) const Padding(padding: EdgeInsets.only(top: 12), child: Text('No open positions yet.')),
    ...positions.values.map((p) => Card(child: ListTile(title: Text(p.symbol), subtitle: Text('Qty ${p.qty}  •  Avg ₹${p.avg.toStringAsFixed(2)}'), trailing: const Icon(Icons.chevron_right)))),
  ]);

  Widget ordersTab() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Order History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
    if (orders.isEmpty) const Text('No orders yet.'), ...orders.map((o) => Card(child: ListTile(leading: const Icon(Icons.receipt_long), title: Text(o), subtitle: const Text('Completed')))),
  ];

  Widget profileTab() => ListView(padding: const EdgeInsets.all(16), children: [
    const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 38)), const SizedBox(height: 12),
    const Center(child: Text('Laxmi Trading User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), const SizedBox(height: 20),
    Card(child: ListTile(leading: const Icon(Icons.account_balance_wallet), title: const Text('Account Balance'), trailing: Text('₹${cash.toStringAsFixed(2)}'))),
    Card(child: ListTile(leading: const Icon(Icons.add_card), title: const Text('Add Funds'), subtitle: const Text('Increase available fund'), onTap: changeFunds)),
    Card(child: ListTile(leading: const Icon(Icons.remove_circle_outline), title: const Text('Reduce Funds'), subtitle: const Text('Decrease available fund'), onTap: changeFunds)),
    const Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('Build status'), subtitle: Text('Prices, charts and funds in this build are simulated. Real-money trading needs broker, market-data and compliance integration.'))),
  ]);
}

class MarketChartPainter extends CustomPainter {
  final List<double> values; final Color lineColor;
  MarketChartPainter(this.values, this.lineColor);
  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce(math.min); final maxV = values.reduce(math.max); final range = (maxV - minV).abs() < .001 ? 1 : (maxV - minV);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i * size.width / (values.length - 1);
      final y = size.height - ((values[i] - minV) / range) * (size.height - 12) - 6;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    final fill = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(fill, Paint()..color = lineColor.withOpacity(.08));
    canvas.drawPath(path, Paint()..color = lineColor..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
  }
  @override bool shouldRepaint(covariant MarketChartPainter oldDelegate) => oldDelegate.values != values || oldDelegate.lineColor != lineColor;
}
