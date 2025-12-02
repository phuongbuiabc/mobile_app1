import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'config/palette.dart';
import 'screens/auth_gate.dart';
import 'providers/tour_provider.dart';
import 'providers/comparison_provider.dart'; // Import Provider MỚI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TourProvider()),
        // Dòng này BẮT BUỘC PHẢI CÓ để sửa lỗi của bạn:
        ChangeNotifierProvider(create: (_) => ComparisonProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivok Travel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Palette.primary,
        scaffoldBackgroundColor: Palette.background,
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: Palette.primary, secondary: Palette.accent),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}