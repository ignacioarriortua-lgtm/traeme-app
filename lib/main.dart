import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth/role_selector_screen.dart';

void main() {
  runApp(const TraemeApp());
}

class TraemeApp extends StatelessWidget {
  const TraemeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'trae.me',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const RoleSelectorScreen(),
    );
  }
}