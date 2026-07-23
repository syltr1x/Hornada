import 'package:flutter/material.dart';

import 'orders_screen.dart';
import 'inventory_screen.dart';
import 'orders_ready_screen.dart';
import 'balance_screen.dart';

import 'new_order_screen.dart';
import 'new_product_screen.dart';
import 'new_spending_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
  
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<OrdersScreenState> _ordersKey = GlobalKey<OrdersScreenState>();
  final GlobalKey<InventoryScreenState> _inventoryKey = GlobalKey<InventoryScreenState>();
  final GlobalKey<BalanceScreenState> _balanceKey = GlobalKey<BalanceScreenState>();
  int _selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      OrdersScreen(key: _ordersKey),
      InventoryScreen(key: _inventoryKey),
      CompletedScreen(),
      BalanceScreen(key: _balanceKey),
    ];
    return Scaffold(
      body: screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
      ? FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const OrderNewScreen(),
            ),
          );

          if (created == true) {
            _ordersKey.currentState?.refreshOrders();
          }
        },
        child: const Icon(Icons.add),
      )
      : _selectedIndex == 1
      ? FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProductNewScreen(),
            ),
          );

          if (created == true) {
            _inventoryKey.currentState?.refreshInventory();
          }
        },
        child: const Icon(Icons.add),
      )
       : _selectedIndex == 2
      ? FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SpendingNewScreen(),
            ),
          );

          if (created == true) {
            _balanceKey.currentState?.refreshBalance();
          }
        },
        child: const Icon(Icons.point_of_sale),
      )
      : _selectedIndex == 3
      ? FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SpendingNewScreen(),
            ),
          );

          if (created == true) {
            _balanceKey.currentState?.refreshBalance();
          }
        },
        child: const Icon(Icons.add),
      )
      :null,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Completos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Balance',
          ),
        ],
      ),
    );
    
  }
}