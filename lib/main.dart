import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart0:convert';

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
  List<dynamic> globalSales = [];
  Map<String, dynamic> globalStats = {"count": 0, "revenue": 0.0, "profit": 0.0, "advance": 0.0};
  bool isReportsUnlocked = false;

  @override
  void initState() {
    super.initState();
    fetchSalesAndStats();
  }

  Future<void> fetchSalesAndStats() async {
    try {
      final salesRes = await http.get(Uri.parse('https://lift-backend-yyzj.onrender.com/get_sales'));
      final statsRes = await http.get(Uri.parse('https://lift-backend-yyzj.onrender.com/get_stats'));

      if (salesRes.statusCode == 200 && statsRes.statusCode == 200) {
        setState(() {
          globalSales = jsonDecode(salesRes.body).reversed.toList(); // Eng so'nggi sotuvlar tepada
          globalStats = jsonDecode(statsRes.body);
        });
      }
    } catch (e) {
      // Offline yoki ulanish xatoligi
    }
  }

  void _navigateToCalculator() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void _unlockReportsWithPin() {
    String pin = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151A23),
        title: const Text("Hisobotlar uchun PIN", style: TextStyle(color: Colors.white)),
        content: TextField(
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          style: const TextStyle(color: Colors.white),
          onChanged: (val) => pin = val,
          decoration: const InputDecoration(
            hintText: "0999",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2563EB))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Bekor qilish", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            onPressed: () {
              if (pin == "0999") {
                setState(() {
                  isReportsUnlocked = true;
                  _currentIndex = 3;
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Xato PIN-kod!")),
                );
              }
            },
            child: const Text("Kirish", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        onNewSaleTap: _navigateToCalculator,
        sales: globalSales,
        stats: globalStats,
        onRefresh: fetchSalesAndStats,
      ),
      CalculatorScreen(onSaleSaved: fetchSalesAndStats),
      CustomersScreen(sales: globalSales),
      ReportsScreen(stats: globalStats, sales: globalSales, isUnlocked: isReportsUnlocked, onUnlockReq: _unlockReportsWithPin),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3 && !isReportsUnlocked) {
            _unlockReportsWithPin();
          } else {
            setState(() => _currentIndex = index);
          }
        },
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

// 1. BOSH SAHIFA
class HomeScreen extends StatelessWidget {
  final VoidCallback onNewSaleTap;
  final List<dynamic> sales;
  final Map<String, dynamic> stats;
  final Future<void> Function() onRefresh;

  const HomeScreen({
    super.key,
    required this.onNewSaleTap,
    required this.sales,
    required this.stats,
    required this.onRefresh,
  });

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
          IconButton(icon: const Icon(Icons.refresh), onPressed: onRefresh),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

              const Text("Jami ko'rsatkichlar", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),

              Row(
                children: [
                  _buildStatCard("${stats['count'] ?? 0}", "Sotuvlar soni", Icons.shopping_bag_outlined, Colors.blue),
                  const SizedBox(width: 10),
                  _buildStatCard("\$${stats['revenue'] ?? 0}", "Jami Tushum", Icons.attach_money, Colors.green),
                  const SizedBox(width: 10),
                  _buildStatCard("\$${stats['advance'] ?? 0}", "Jami Avans", Icons.account_balance_wallet, Colors.amber),
                ],
              ),
              const SizedBox(height: 20),

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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("So'nggi sotuvlar", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text("${sales.length} ta sotuv", style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 13)),
                ],
              ),
              const SizedBox(height: 10),

              sales.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(color: const Color(0xFF151A23), borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text("Hozircha sotuvlar yo'q", style: TextStyle(color: Colors.grey))),
                    )
                  : Column(
                      children: sales.take(5).map((s) => _buildSaleTile(s)).toList(),
                    ),
            ],
          ),
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
            FittedBox(child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white))),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  static Widget _buildSaleTile(dynamic sale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF151A23), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          const Icon(Icons.apartment, color: Color(0xFF3B82F6)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sale['client_name'] ?? "Noma'lum", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text("${sale['lift_info']} • ${sale['seller']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("\$${sale['selling_price']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(sale['date'] ?? "", style: const TextStyle(color: Colors.green, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }
}

// 2. KALKULYATOR SAHIFASI
class CalculatorScreen extends StatefulWidget {
  final VoidCallback onSaleSaved;
  const CalculatorScreen({super.key, required this.onSaleSaved});

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
        widget.onSaleSaved();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Sotuv muvaffaqiyatli saqlandi!")));
        clientController.clear();
        advanceController.clear();
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
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF151A23),
              value: selectedSeller,
              decoration: _inputDecoration("Sotuvchi (Sherik)"),
              items: sellers.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => selectedSeller = val!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: clientController,
              decoration: _inputDecoration("Mijoz / Ob'ekt nomi", hint: "Mijoz yoki ob'ekt nomini kiriting"),
            ),
            const SizedBox(height: 12),
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
            TextField(
              controller: advanceController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("Olingan avans (\$)"),
            ),
            const SizedBox(height: 15),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(onPressed: () => setState(() => discount += 50), child: const Text("-\$50")),
                OutlinedButton(onPressed: () => setState(() => discount += 100), child: const Text("-\$100")),
                OutlinedButton(onPressed: () => setState(() => discount += 200), child: const Text("-\$200")),
              ],
            ),
            const SizedBox(height: 20),
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
}

// 3. MIJOZLAR SAHIFASI
class CustomersScreen extends StatelessWidget {
  final List<dynamic> sales;
  const CustomersScreen({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E14),
        title: const Text("Mijozlar Bazasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: sales.isEmpty
          ? const Center(child: Text("Mijozlar topilmadi", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final item = sales[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151A23),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF2563EB),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['client_name'] ?? "Noma'lum", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text("Lift: ${item['lift_info']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          Text("Sherik: ${item['seller']}", style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("\$${item['selling_price']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text("Avans: \$${item['advance_payment']}", style: const TextStyle(color: Colors.amber, fontSize: 11)),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// 4. HISOBOTLAR SAHIFASI (0999 PIN VA SOF FOYDA BILAN)
class ReportsScreen extends StatelessWidget {
  final Map<String, dynamic> stats;
  final List<dynamic> sales;
  final bool isUnlocked;
  final VoidCallback onUnlockReq;

  const ReportsScreen({
    super.key,
    required this.stats,
    required this.sales,
    required this.isUnlocked,
    required this.onUnlockReq,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E14),
        title: const Text("Moliyaviy Hisobotlar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: !isUnlocked
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 60, color: Color(0xFF2563EB)),
                  const SizedBox(height: 15),
                  const Text("Hisobotlar bo'limi himoyalangan", style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                    onPressed: onUnlockReq,
                    child: const Text("PIN kiritish (0999)", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Umumiy Moliyaviy Holat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 15),

                  _buildReportCard("JAMI SOF FOYDA", "\$${stats['profit'] ?? 0}", Icons.trending_up, Colors.green),
                  const SizedBox(height: 10),
                  _buildReportCard("JAMI TUSHUM (SOTUV)", "\$${stats['revenue'] ?? 0}", Icons.attach_money, Colors.blue),
                  const SizedBox(height: 10),
                  _buildReportCard("OLINGAN AVANSLAR", "\$${stats['advance'] ?? 0}", Icons.account_balance_wallet, Colors.amber),

                  const SizedBox(height: 25),
                  const Text("Sotuvchilar bo'yicha hisobot", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),

                  sales.isEmpty
                      ? const Text("Ma'lumot mavjud emas", style: TextStyle(color: Colors.grey))
                      : Column(
                          children: sales.map((s) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFF151A23), borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${s['seller']} -> ${s['client_name']}", style: const TextStyle(color: Colors.white)),
                                  Text("Sof Foyda: +\$${s['profit']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }).toList(),
                        )
                ],
              ),
            ),
    );
  }

  static Widget _buildReportCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151A23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(height: 4),
              Text(amount, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}

// 5. PROFIL SAHIFASI
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E14),
        title: const Text("Profil va Sozlamalar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, backgroundColor: Color(0xFF2563EB), child: Icon(Icons.apartment, size: 40, color: Colors.white)),
            const SizedBox(height: 15),
            const Text("SPACE-S LIFT SYSTEM", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Versiya: 2.0.0 (Release)", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.cloud_done, color: Colors.green),
              title: const Text("Server Holati"),
              subtitle: const Text("Render Server Ulangan"),
              tileColor: const Color(0xFF151A23),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ],
        ),
      ),
    );
  }
}
