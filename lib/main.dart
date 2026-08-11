import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const SpaceSLiftApp());
}

class SpaceSLiftApp extends StatelessWidget {
  const SpaceSLiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPACE-S LIFT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0E14),
        primaryColor: const Color(0xFF2563EB),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2563EB),
          surface: Color(0xFF151A23),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToCalculator() {
    setState(() {
      _currentIndex = 1; // Kalkulyator sahifasiga o'tkazish
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(onNewSaleTap: _navigateToCalculator),
      const CalculatorScreen(),
      const Center(child: Text("Mijozlar Bazasi", style: TextStyle(color: Colors.white))),
      const Center(child: Text("Hisobotlar", style: TextStyle(color: Colors.white))),
      const Center(child: Text("Profil va Sozlamalar", style: TextStyle(color: Colors.white))),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF151A23),
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Bosh sahifa"),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "Sotuvlar"),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: "Mijozlar"),
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: "Hisobotlar"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

// 1. BOSH SAHIFA (DASHBOARD)
class HomeScreen extends StatelessWidget {
  final VoidCallback onNewSaleTap;
  const HomeScreen({super.key, required this.onNewSaleTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E14),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.apartment, color: Color(0xFF3B82F6)),
            ),
            const SizedBox(width: 10),
            const Text("SPACE-S LIFT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salomlashish kartochkasi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151A23),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Assalomu alaykum,", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      SizedBox(height: 4),
                      Text("Said", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("Bugungi ishlaringiz zo'r!", style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12)),
                    ],
                  ),
                  Icon(Icons.bar_chart, color: Color(0xFF3B82F6), size: 40),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text("Bugungi ko'rsatkichlar", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),

            // Metrics Row
            Row(
              children: [
                _buildStatCard("12", "Sotuvlar bugun", Icons.shopping_bag_outlined, Colors.blue),
                const SizedBox(width: 10),
                _buildStatCard("\$245,000", "Tushum bugun", Icons.attach_money, Colors.green),
                const SizedBox(width: 10),
                _buildStatCard("\$38,500", "Sof foyda bugun", Icons.trending_up, Colors.amber),
              ],
            ),
            const SizedBox(height: 20),

            // Yangi lift sotish tugmasi
            InkWell(
              onTap: onNewSaleTap,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.add, color: Colors.white)),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Yangi lift sotish", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Yangi sotuv qo'shish", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // So'nggi sotuvlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("So'nggi sotuvlar", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                TextButton(onPressed: () {}, child: const Text("Barchasi >", style: TextStyle(color: Color(0xFF3B82F6)))),
              ],
            ),
            _buildRecentSaleTile("Chilonzor Plaza", "7 qavat • 1000 kg", "\$20,500", "Bugun, 10:30"),
            _buildRecentSaleTile("Magic City", "9 qavat • 630 kg", "\$18,300", "Bugun, 09:15"),
            _buildRecentSaleTile("Nurobod Residence", "5 qavat • 1000 kg", "\$22,000", "Kecha, 17:45"),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF151A23), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  static Widget _buildRecentSaleTile(String title, String subtitle, String price, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF151A23), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          const Icon(Icons.apartment, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(time, style: const TextStyle(color: Colors.green, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }
}

// 2. KALKULYATOR SAHIFASI (YANGI LIFT SOTISH)
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String selectedSeller = 'Toxirjon';
  final List<String> sellers = ['Toxirjon', 'Saidaxmad', 'Avazbek', 'Mavlonjon'];

  int selectedFloor = 7;
  String selectedCapacity = '1000 kg';
  bool hasDispecher = true;
  bool isGold = false;
  bool isPanorama = false;
  bool hasKarkaz = false;

  double discount = 0.0;
  final TextEditingController clientController = TextEditingController();
  final TextEditingController advanceController = TextEditingController();

  double getBaseFactoryPrice() {
    if (hasDispecher) {
      return (selectedFloor <= 7) ? ((selectedCapacity == '1000 kg') ? 18500.0 : 18000.0) : 18500.0 + ((selectedFloor - 7) * 500.0);
    } else {
      return (selectedFloor <= 3) ? ((selectedCapacity == '1000 kg') ? 16500.0 : 16000.0) : 16500.0 + ((selectedFloor - 3) * 500.0);
    }
  }

  double getKarkazPrice() => hasKarkaz ? 1500.0 : 0.0;
  
  double getOptionsPrice() {
    double opts = 0.0;
    if (isGold) opts += 500.0;
    if (isPanorama) opts += 1500.0;
    return opts;
  }

  double getTotalCost() => getBaseFactoryPrice() + getKarkazPrice() + getOptionsPrice();
  double getSellingPrice() => (getTotalCost() + 2000.0) - discount;

  Future<void> sendToExcelServer() async {
    final url = Uri.parse('https://lift-backend-yyzj.onrender.com/add_sale');
    final body = {
      "seller": selectedSeller,
      "client_name": clientController.text.isEmpty ? "Noma'lum" : clientController.text,
      "lift_info": "$selectedFloor Qavat, $selectedCapacity, ${hasDispecher ? 'Dispecher' : 'Oddiy'}",
      "factory_price": getBaseFactoryPrice(),
      "has_karkaz": hasKarkaz,
      "selling_price": getSellingPrice(),
      "advance_payment": double.tryParse(advanceController.text) ?? 0.0,
      "delivery_days": 30
    };

    try {
      final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Sotuv muvaffaqiyatli saqlandi!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Xatolik: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E14),
        title: const Text("Yangi lift sotish", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Asosiy ma'lumotlar", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),

            // Sotuvchi Dropdown
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF151A23),
              value: selectedSeller,
              decoration: _inputDecoration("Sotuvchi (Sherik)"),
              items: sellers.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => selectedSeller = val!),
            ),
            const SizedBox(height: 12),

            // Mijoz Nomi Input
            TextField(
              controller: clientController,
              decoration: _inputDecoration("Mijoz / Ob'ekt nomi", hint: "Mijoz yoki ob'ekt nomini kiriting"),
            ),
            const SizedBox(height: 12),

            // Qavat va Quvvat
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: selectedFloor.toString(),
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("Bino qavati"),
                    onChanged: (val) => setState(() => selectedFloor = int.tryParse(val) ?? 7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF151A23),
                    value: selectedCapacity,
                    decoration: _inputDecoration("Yuk quvvati"),
                    items: ['450 kg', '630 kg', '800 kg', '1000 kg'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => selectedCapacity = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text("Qo'shimcha opsiyalar", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(color: const Color(0xFF151A23), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
              child: Column(
                children: [
                  SwitchListTile(
                    activeColor: const Color(0xFF3B82F6),
                    title: const Text("Karkaz o'rnatish"),
                    subtitle: const Text("+\$1,500", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    value: hasKarkaz,
                    onChanged: (val) => setState(() => hasKarkaz = val),
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  CheckboxListTile(
                    activeColor: const Color(0xFF3B82F6),
                    title: const Text("GOLD dizayn"),
                    subtitle: const Text("+\$500", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    value: isGold,
                    onChanged: (val) => setState(() => isGold = val!),
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  CheckboxListTile(
                    activeColor: const Color(0xFF3B82F6),
                    title: const Text("PANORAMNIY dizayn"),
                    subtitle: const Text("+\$1,500", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    value: isPanorama,
                    onChanged: (val) => setState(() => isPanorama = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text("Moliyaviy ma'lumotlar", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),

            TextField(
              controller: advanceController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("Olingan avans (\$)"),
            ),
            const SizedBox(height: 15),

            // SOTISH NARXI TABLOSI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF151A23),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  const Text("SOTISH NARXI", style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1.2)),
                  const SizedBox(height: 5),
                  Text("\$${getSellingPrice().toStringAsFixed(0)}", style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6))),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Chegirma tugmalari
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(onPressed: () => setState(() => discount += 50), child: const Text("-\$50")),
                OutlinedButton(onPressed: () => setState(() => discount += 100), child: const Text("-\$100")),
                OutlinedButton(onPressed: () => setState(() => discount += 200), child: const Text("-\$200")),
              ],
            ),
            const SizedBox(height: 20),

            // HISOB-KITOB TAFSILOTI (CHEK KO'RINISHI)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF151A23), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Hisob-kitob tafsiloti", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                  const SizedBox(height: 10),
                  _buildReceiptRow("Asosiy narx", "\$${getBaseFactoryPrice().toStringAsFixed(0)}"),
                  _buildReceiptRow("Karkaz o'rnatish", "+\$${getKarkazPrice().toStringAsFixed(0)}"),
                  _buildReceiptRow("Jami qo'shimcha", "+\$${getOptionsPrice().toStringAsFixed(0)}"),
                  _buildReceiptRow("Chegirma", "-\$${discount.toStringAsFixed(0)}"),
                  const Divider(color: Colors.white24),
                  _buildReceiptRow("Yakuniy narx", "\$${getSellingPrice().toStringAsFixed(0)}", isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // SAQLASH TUGMASI
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text("Sotuvni saqlash", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                onPressed: sendToExcelServer,
              ),
            )
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.grey),
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF151A23),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
    );
  }

  static Widget _buildReceiptRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isTotal ? Colors.white : Colors.grey, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(color: isTotal ? const Color(0xFF3B82F6) : Colors.white, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
