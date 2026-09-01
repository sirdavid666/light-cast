import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/role_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LightCastApp()));
}

class LightCastApp extends StatelessWidget {
  const LightCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LightCast',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.amber,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const RoleSelectionScreen(),
    );
  }
}
