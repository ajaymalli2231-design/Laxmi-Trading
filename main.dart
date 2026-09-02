import 'package:flutter/material.dart';

void main() => runApp(const LaxmiTradingApp());

class LaxmiTradingApp extends StatelessWidget {
  const LaxmiTradingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Laxmi Trading',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const LoginPage(),
    );
  }
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
      const Text('PAPER TRADING', style: TextStyle(color: Colors.white70, letterSpacing: 2)),
      const SizedBox(height: 48),
      TextField(controller: phone, keyboardType: TextInputType.phone, style: const TextStyle(color: Colors.white), decoration: _dec('Mobile Number', Icons.phone)),
      if (sent) ...[
        const SizedBox(height: 14),
        TextField(controller: otp, keyboardType: TextInputType.number, maxLength: 6, style: const TextStyle(color: Colors.white), decoration: _dec('6-digit OTP (demo: 123456)', Icons.lock)),
      ],
      const SizedBox(height: 18),
      SizedBox(width: double.infinity, child: FilledButton(
        onPressed: () { if (!sent) { setState(() => sent = true); } else if (otp.text == '123456') { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())); } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo OTP is 123456'))); } },
        child: Text(sent ? 'VERIFY & LOGIN' : 'SEND OTP'),
      )),
      const SizedBox(height: 14),
      const Text('Demo only • All funds and trades are virtual', style: TextStyle(color: Colors.white54)),
    ]))),
  );
  InputDecoration _dec(String label, IconData icon) => InputDecoration(labelText: label, prefixIcon: Icon(icon), labelStyle: const TextStyle(color: Colors.white70), filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)));
}

class Market { final String name, value, change; final bool up; const Market(this.name,this.value,this.change,this.up); }
const markets = [
  Market('NIFTY 50','24,341.15','+62.45 (0.26%)',true),
  Market('BANK NIFTY','52,231.20','+178.90 (0.34%)',true),
  Market('FINNIFTY','23,045.80','+82.10 (0.36%)',true),
  Market('SENSEX','80,245.10','+201.45 (0.25%)',true),
];

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=>_HomePageState(); }
class _HomePageState extends State<HomePage> {
  int tab=0; double cash=500000; final Map<String,int> positions={};
  void trade(Market m, bool buy) {
    final price=double.parse(m.value.replaceAll(',',''));
    if (buy && cash < price) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient virtual funds'))); return; }
    setState(() { if(buy){cash-=price; positions[m.name]=(positions[m.name]??0)+1;} else if((positions[m.name]??0)>0){cash+=price; positions[m.name]=(positions[m.name]??0)-1;} });
  }
  @override Widget build(BuildContext context) {
    final pages=[marketPage(), portfolioPage(), const Center(child: Text('Orders')), const Center(child: Text('Profile'))];
    return Scaffold(appBar: AppBar(title: const Text('LAXMI TRADING'), actions:[IconButton(onPressed:(){},icon:const Icon(Icons.notifications_none))]), body: pages[tab], bottomNavigationBar: NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:const [NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'Home'),NavigationDestination(icon:Icon(Icons.pie_chart_outline),label:'Portfolio'),NavigationDestination(icon:Icon(Icons.receipt_long),label:'Orders'),NavigationDestination(icon:Icon(Icons.person_outline),label:'Profile')]),);
  }
  Widget marketPage()=>ListView(padding:const EdgeInsets.all(16),children:[Card(child:ListTile(title:const Text('Virtual Balance'),subtitle:const Text('Paper Trading Fund'),trailing:Text('₹${cash.toStringAsFixed(2)}',style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)))), const SizedBox(height:12), const Text('Indian Indices',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)), ...markets.map((m)=>Card(child:ListTile(onTap:()=>showTrade(m),title:Text(m.name),subtitle:Text(m.value),trailing:Text(m.change,style:TextStyle(color:m.up?Colors.green:Colors.red,fontWeight:FontWeight.bold)))))]);
  Widget portfolioPage()=>ListView(padding:const EdgeInsets.all(16),children:[Text('Available Cash: ₹${cash.toStringAsFixed(2)}',style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:20),...positions.entries.where((e)=>e.value>0).map((e)=>ListTile(title:Text(e.key),trailing:Text('${e.value} unit(s)'))), if(positions.values.every((v)=>v==0)) const Text('No open paper positions yet.')]);
  void showTrade(Market m)=>showModalBottomSheet(context:context,builder:(_)=>Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.stretch,children:[Text(m.name,style:const TextStyle(fontSize:24,fontWeight:FontWeight.bold)),Text('₹${m.value}'),const SizedBox(height:20),Row(children:[Expanded(child:FilledButton(onPressed:(){Navigator.pop(context);trade(m,true);},child:const Text('BUY'))),const SizedBox(width:12),Expanded(child:FilledButton(style:FilledButton.styleFrom(backgroundColor:Colors.red),onPressed:(){Navigator.pop(context);trade(m,false);},child:const Text('SELL')))])])));
}
