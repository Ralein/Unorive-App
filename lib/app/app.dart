import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unorive/app/router.dart';
import 'package:unorive/core/theme/theme.dart';

/// The root Widget of the Unorive application.
class UnoriveApp extends ConsumerWidget {
  const UnoriveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Unorive',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to Dark mode first as requested
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
