import 'package:flutter/material.dart';

import '../screens/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Hornada',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color.fromARGB(255, 55, 67, 77), useMaterial3: true),
      home: const HomeScreen(),
      
    );
    
  }
}
