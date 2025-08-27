import 'package:flutter/material.dart';
import 'package:step_by_step_calculator/screens/home.dart';

void main() {
  runApp(const StepCalcApp());
}

class StepCalcApp extends StatelessWidget {
  const StepCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora paso a paso',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2A7A7B)),
        useMaterial3: true,
        fontFamily: 'monospace',
      ),
      home: const HomePage(),
    );
  }
}
