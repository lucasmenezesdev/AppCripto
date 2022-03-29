import 'package:criptol/configs/app_settings.dart';
import 'package:criptol/repositories/conta_repository.dart';
import 'package:criptol/repositories/favoritas_repository.dart';
import 'package:criptol/repositories/moeda_repository.dart';
import 'package:criptol/services/auth_service.dart';
import 'package:criptol/services/firebase_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'configs/hive_config.dart';
import 'my_app.dart';

void main() async {
  final config = FirebaseConfig();
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: config.apiKey,
      appId: config.appId,
      messagingSenderId: config.messagingSenderId,
      projectId: config.projectId,
      authDomain: config.authDomain,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(
            create: (context) => ContaRepository(
                  moedas: context.read<MoedaRepository>(),
                )),
        ChangeNotifierProvider(create: (context) => AppSettings()),
        ChangeNotifierProvider(create: (context) => MoedaRepository()),
        ChangeNotifierProvider(
            create: (context) => FavoritasRepository(
                  auth: context.read<AuthService>(),
                  moedas: context.read<MoedaRepository>(),
                )),
        ChangeNotifierProvider(create: (context) => AppSettings())
      ],
      child: const MyApp(),
    ),
  );
}
