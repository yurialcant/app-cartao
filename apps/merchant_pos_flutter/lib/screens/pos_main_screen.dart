import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class POSMainScreen extends StatefulWidget {
  @override
  _POSMainScreenState createState() => _POSMainScreenState();
}

class _POSMainScreenState extends State<POSMainScreen> {
  String terminalStatus = 'ONLINE';
  double totalSales = 0.0;
  int transactionCount = 0;
  String operatorName = 'Operator';
  String shiftStatus = 'ACTIVE';
  
  @override
  void initState() {
    super.initState();
    loadTerminalStatus();
  }
  
  Future<void> loadTerminalStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/dashboard/sales'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalSales = (data['totalSales'] ?? 0).toDouble();
          transactionCount = data['totalTransactions'] ?? 0;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Merchant POS'),
        backgroundColor: Color(0xFF007BFF),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Shift: $shiftStatus',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(blurRadius: 4, color: Colors.grey.withOpacity(0.3))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Terminal Status', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: terminalStatus == 'ONLINE' ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          terminalStatus,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'R\$ ${totalSales.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  Text('Today\'s Sales', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text(
                    '$transactionCount transactions',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Action Buttons
            ElevatedButton.icon(
              onPressed: () {
                // QR/NFC scanning
              },
              icon: Icon(Icons.qr_code_2),
              label: Text('Scan Payment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF007BFF),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: () {
                // Manual entry
              },
              icon: Icon(Icons.edit),
              label: Text('Manual Entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF28A745),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: () {
                // Refund
              },
              icon: Icon(Icons.undo),
              label: Text('Refund'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFC107),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: () {
                // Print receipt
              },
              icon: Icon(Icons.print),
              label: Text('Print Last Receipt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Quick Info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Operator: $operatorName', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Terminal: 001', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  SizedBox(height: 8),
                  Text('Shift Duration: 08:00 - 16:00', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
