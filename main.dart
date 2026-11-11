import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'services/chat_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = ChatStorage();
  await storage.init();
  runApp(SuzaneApp(storage: storage));
}

class SuzaneApp extends StatelessWidget {
  const SuzaneApp({super.key, required this.storage});
  final ChatStorage storage;

  @override
  Widget build(BuildContext context) {
    const violet = Color(0xFF8B5CF6);
    return MaterialApp(
      title: 'SUZANE AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090914),
        colorScheme: ColorScheme.fromSeed(
          seedColor: violet,
          brightness: Brightness.dark,
          surface: const Color(0xFF111124),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF090914),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: HomeScreen(storage: storage),
    );
  }
}
