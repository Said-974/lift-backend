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
      title: 'Lift Kalkulyatori',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
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
        title: const Text("PIN-kodni kiriting"),
        content: TextField(
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          onChanged: (val) => pin = val,
          decoration: const InputDecoration(hintText: "****"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Bekor qilish"),
          ),
          ElevatedButton(
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
            child: const Text("Kirish"),
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
          const SnackBar(content: Text("Sotuv bulutli serverga saqlandi!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Serverga ulanishda xatolik: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SPACE-S Lift Kalkulyatori"),
        actions: [
          IconButton(
            icon: Icon(isProfitVisible ? Icons.lock_open : Icons.lock),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSeller,
              decoration: const InputDecoration(labelText: "Sotuvchi (Sherik)"),
              items: sellers.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => selectedSeller = val!),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: clientController,
              decoration: const InputDecoration(labelText: "Mijoz / Ob'ekt Nomi"),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: selectedFloor.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Bino Qavati"),
                    onChanged: (val) => setState(() => selectedFloor = int.tryParse(val) ?? 7),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCapacity,
                    decoration: const InputDecoration(labelText: "Yuk quvvati"),
                    items: ['450 kg', '630 kg', '800 kg', '1000 kg']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedCapacity = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            SwitchListTile(
              title: const Text("Karkaz o'rnatish (+\$1500)"),
              value: hasKarkaz,
              onChanged: (val) => setState(() => hasKarkaz = val),
            ),
            CheckboxListTile(
              title: const Text("GOLD dizayn (+\$500)"),
              value: isGold,
              onChanged: (val) => setState(() => isGold = val!),
            ),
            CheckboxListTile(
              title: const Text("PANORAMNIY dizayn (+\$1500)"),
              value: isPanorama,
              onChanged: (val) => setState(() => isPanorama = val!),
            ),

            const SizedBox(height: 15),
            TextField(
              controller: advanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Olingan Avans (\$)"),
            ),

            const Divider(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Column(
                children: [
                  const Text("SOTISH NARXI", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(
                    "\$${getSellingPrice().toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  if (isProfitVisible) ...[
                    const SizedBox(height: 10),
                    Text(
                      "SOF FOYDA: +\$${getProfit().toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (getProfit() - 50 >= 1000) setState(() => discount += 50);
                  },
                  child: const Text("-\$50"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (getProfit() - 100 >= 1000) setState(() => discount += 100);
                  },
                  child: const Text("-\$100"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (getProfit() - 200 >= 1000) setState(() => discount += 200);
                  },
                  child: const Text("-\$200"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload),
                label: const Text("SOTUVNI SAQLASH"),
                onPressed: sendToExcelServer,
              ),
            )
          ],
        ),
      ),
    );
  }
}
