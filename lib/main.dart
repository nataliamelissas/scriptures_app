import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ScripturesApp()));
}

class ScripturesApp extends StatelessWidget {
  const ScripturesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scriptures',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
