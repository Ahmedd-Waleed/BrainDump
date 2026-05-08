/// App Root
///
/// Wraps the app with all needed providers (theme, settings, auth)
/// and configures MaterialApp with light/dark themes.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth_gate.dart';
import 'services/auth_service.dart';

class BrainDumpApp extends StatelessWidget {
  const BrainDumpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'BrainDump AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
