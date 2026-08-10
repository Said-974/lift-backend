import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const LiftApp());
}

class LiftApp extends StatelessWidget {
  const LiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPACE-S Lift',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121418),
        primaryColor: const Color(0xFFD4AF37),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFF00E676),
          surface: Color(0xFF1E222A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF181B20),
          elevation: 4,
          titleTextStyle: TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: const LiftCalculatorScreen(),
    );
  }
}

class LiftCalculatorScreen extends StatefulWidget {
  const LiftCalculatorScreen({super.key});

  @override
  State<LiftCalculatorScreen> createState() => _LiftCalculatorScreenState();
}

class _LiftCalculatorScreenState extends State<LiftCalculatorScreen> {
  String selectedSeller = 'Toxirjon';
  final List<String> sellers = ['Toxirjon', 'Saidaxmad', 'Avazbek', 'Mavlonjon'];
  
  int selectedFloor = 7;
  String selectedCapacity = '1000 kg';
  bool hasDispecher = true;
  bool isGold = false;
  bool isPanorama = false;
  bool isDoubleDoor = false;
  bool hasKarkaz = false;

  double discount = 0.0;
  bool isProfitVisible = false;
  
  final TextEditingController clientController = TextEditingController();
  final TextEditingController advanceController = TextEditingController();

  double getBaseFactoryPrice() {
    if (hasDispecher) {
      if (selectedFloor <= 7) {
        return (selectedCapacity == '1000 kg') ? 18500.0 : 18000.0;
      } else {
        return 18500.0 + ((selectedFloor - 7) * 500.0);
      }
    } else {
      if (selectedFloor <= 3) {
        return (selectedCapacity == '1000 kg') ? 16500.0 : 16000.0;
      } else {
        return 16500.0 + ((selectedFloor - 3) * 500.0);
      }
    }
  }

  double getTotalCost() {
    double base = getBaseFactoryPrice();
    if (isGold) base += 500;
    if (isPanorama) base += 1500;
    if (isDoubleDoor) base += (hasDispecher ? 1200 : 700);
    
    double karkaz = hasKarkaz ? 1500.0 : 0.0;
    return base + karkaz;
  }

  double getSellingPrice() {
    double idealPrice = getTotalCost() + 2000.0;
    return idealPrice - discount;
  }

  double getProfit() {
    return getSellingPrice() - getTotalCost();
  }

  void _showPinDialog() {
    String pin = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E222A),
        title: const Text("PIN-kodni kiriting", style: TextStyle(color: Colors.white)),
        content: TextField(
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          style: const TextStyle(color: Colors.white),
          onChanged: (val) => pin = val,
          decoration: const InputDecoration(
            hintText: "****",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Bekor qilish", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
            onPressed: () {
              if (pin == "9909") {
                setState(() => isProfitVisible = true);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Xato PIN-kod!")),
                );
              }
            },
            child: const Text("Kirish", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Sotuv bulutli serverga saqlandi!", style: TextStyle(color: Colors.white)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Serverga ulanishda xatolik: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SPACE-S LIFT"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isProfitVisible ? Icons.lock_open : Icons.lock,
              color: const Color(0xFFD4AF37),
            ),
            onPressed: () {
              if (isProfitVisible) {
                setState(() => isProfitVisible = false);
              } else {
                _showPinDialog();
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 40.0), // Pastga qo'shimcha joy qoldirildi
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sotuvchi Tanlovi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E222A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  dropdownColor: const Color(0xFF1E222A),
                  value: selectedSeller,
                  decoration: const InputDecoration(
                    labelText: "Sotuvchi (Sherik)",
                    labelStyle: TextStyle(color: Color(0xFFD4AF37)),
                    border: InputBorder.none,
                  ),
                  items: sellers.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (val) => setState(() => selectedSeller = val!),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Mijoz Nomi
            TextField(
              controller: clientController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Mijoz / Ob'ekt Nomi",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1E222A),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Qavat va Quvvat
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: selectedFloor.toString(),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Bino Qavati",
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1E222A),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white24),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (val) => setState(() => selectedFloor = int.tryParse(val) ?? 7),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E222A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: const Color(0xFF1E222A),
                        value: selectedCapacity,
                        decoration: const InputDecoration(
                          labelText: "Yuk quvvati",
                          labelStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        items: ['450 kg', '630 kg', '800 kg', '1000 kg']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white))))
                            .toList(),
                        onChanged: (val) => setState(() => selectedCapacity = val!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Opsiyalar Box
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E222A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    activeColor: const Color(0xFFD4AF37),
                    title: const Text("Karkaz o'rnatish (+\$1500)", style: TextStyle(color: Colors.white)),
                    value: hasKarkaz,
                    onChanged: (val) => setState(() => hasKarkaz = val),
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  CheckboxListTile(
                    activeColor: const Color(0xFFD4AF37),
                    checkColor: Colors.black,
                    title: const Text("GOLD dizayn (+\$500)", style: TextStyle(color: Colors.white)),
                    value: isGold,
                    onChanged: (val) => setState(() => isGold = val!),
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  CheckboxListTile(
                    activeColor: const Color(0xFFD4AF37),
                    checkColor: Colors.black,
                    title: const Text("PANORAMNIY dizayn (+\$1500)", style: TextStyle(color: Colors.white)),
                    value: isPanorama,
                    onChanged: (val) => setState(() => isPanorama = val!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Avans Input
            TextField(
              controller: advanceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Olingan Avans (\$)",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1E222A),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tablo (Natija ekrani)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A2E39), Color(0xFF1E222A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text("SOTISH NARXI", style: TextStyle(fontSize: 13, color: Colors.grey, letterSpacing: 1.2)),
                  const SizedBox(height: 5),
                  Text(
                    "\$${getSellingPrice().toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                      shadows: [Shadow(color: Color(0xAAD4AF37), blurRadius: 10)],
                    ),
                  ),
                  if (isProfitVisible) ...[
                    const Divider(color: Colors.white24, height: 20),
                    Text(
                      "SOF FOYDA: +\$${getProfit().toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00E676)),
                    ),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Chegirma tugmalari
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD4AF37))),
                  onPressed: () {
                    if (getProfit() - 50 >= 1000) setState(() => discount += 50);
                  },
                  child: const Text("-\$50", style: TextStyle(color: Color(0xFFD4AF37))),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD4AF37))),
                  onPressed: () {
                    if (getProfit() - 100 >= 1000) setState(() => discount += 100);
                  },
                  child: const Text("-\$100", style: TextStyle(color: Color(0xFFD4AF37))),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD4AF37))),
                  onPressed: () {
                    if (getProfit() - 200 >= 1000) setState(() => discount += 200);
                  },
                  child: const Text("-\$200", style: TextStyle(color: Color(0xFFD4AF37))),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Sotuvni saqlash tugmasi
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.cloud_upload, color: Colors.black),
                label: const Text(
                  "SOTUVNI SAQLASH",
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                onPressed: sendToExcelServer,
              ),
            )
          ],
        ),
      ),
    );
  }
}
