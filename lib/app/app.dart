import 'package:flutter/material.dart';
import 'package:unorive/core/theme/theme.dart';
import 'package:unorive/app/router.dart';

/// The root Widget of the Unorive application.
class UnoriveApp extends StatelessWidget {
  const UnoriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Unorive',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to Dark mode first as requested
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
