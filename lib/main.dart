import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SCRIPTURE_BASE_PATH is a local filesystem path with no meaning on web,
  // so skip loading .env there (avoids a 404 fetch for the bundled dotfile).
  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env is optional; local fallback simply yields no books.
    }
  }
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
