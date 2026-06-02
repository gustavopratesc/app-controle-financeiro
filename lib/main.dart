import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/login_view.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // --- NOVA CONEXÃO COM A NUVEM ---
  // --- NOVA CONEXÃO COM A NUVEM ---
  await Supabase.initialize(
    url: 'https://gntwuseopkogheougyfr.supabase.co',
    anonKey: 'sb_publishable_uRt-T0u0rWTCSPWUsRC3ZQ_ivYERLRj',
  );

  runApp(const ProviderScope(child: ControleFinanceiroApp()));
}

class ControleFinanceiroApp extends StatelessWidget {
  const ControleFinanceiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle Financeiro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const LoginView(), // A View de Login se torna a tela principal
    );
  }
}

