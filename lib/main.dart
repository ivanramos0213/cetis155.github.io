import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plantilive',
      theme: ThemeData(
        useMaterial3: true,
        // Color principal: Verde Bosque profundo
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B3022),
          primary: const Color(0xFF2D4F32),
          surface: const Color(0xFFFDFDFB), // Un blanco crema muy sutil
        ),
        // Tipografía elegante
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Color(0xFF1B3022), fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Color(0xFF4A4A4A)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFDFDFB),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Color(0xFF1B3022), fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      home: const LoginPage(),
    );
  }
}