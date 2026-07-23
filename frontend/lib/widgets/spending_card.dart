import 'package:flutter/material.dart';

import 'package:frontend/models/balance.dart';
import 'package:frontend/screens/detail_spending_screen.dart';

class OrderCard extends StatelessWidget {
  final Balance balance;
  final VoidCallback onDelete;
  final VoidCallback onReady;
  // final Future<void> Function(int id, String method) onPay;
  

  const OrderCard({
    super.key,
    required this.balance,
    required this.onDelete,
    required this.onReady,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text("${balance.person} | ${balance.reason}"),
        subtitle: Text("${balance.total.toString()} | ${balance.method}"),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(
                  orderId: balance.id,
              ),
            ),
          );
        },

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}