import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/vpn_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VpnApp());
}

class VpnApp extends StatelessWidget {
  const VpnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VpnProvider(),
      child: MaterialApp(
        title: 'Flutter VPN',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0D0F14),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4FFFB0),
            surface: Color(0xFF161A22),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
