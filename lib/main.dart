import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/plan_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlanProvider(),
      child: MaterialApp(
        title: 'متابعة حفظ القرآن الكريم',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
        locale: const Locale('ar', 'SA'), // Arabic locale
        // RTL text direction is already set in the HomeScreen
      ),
    );
  }
}
