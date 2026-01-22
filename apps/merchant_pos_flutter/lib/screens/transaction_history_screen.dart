import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<Map<String, dynamic>> transactions = [
    {
      'id': 'TXN001',
      'amount': 150.00,
      'type': 'SALE',
      'time': '10:30',
      'status': 'COMPLETED',
    },
    {
      'id': 'TXN002',
      'amount': 250.00,
      'type': 'SALE',
      'time': '10:45',
      'status': 'COMPLETED',
    },
    {
      'id': 'TXN003',
      'amount': 50.00,
      'type': 'REFUND',
      'time': '11:00',
      'status': 'COMPLETED',
    },
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        backgroundColor: Color(0xFF007BFF),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final txn = transactions[index];
          return _buildTransactionItem(txn);
        },
      ),
    );
  }
  
  Widget _buildTransactionItem(Map<String, dynamic> txn) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: txn['type'] == 'SALE' ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            txn['type'] == 'SALE' ? Icons.add : Icons.undo,
            color: Colors.white,
          ),
        ),
        title: Text('${txn['type']} - ${txn['id']}'),
        subtitle: Text(txn['time']),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'R\$ ${txn['amount'].toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Chip(
              label: Text(txn['status'], style: TextStyle(fontSize: 10)),
              backgroundColor: txn['status'] == 'COMPLETED' ? Colors.green : Colors.orange,
              labelStyle: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
