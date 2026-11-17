import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/plain/ui/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PlainPleaseApp()));
}

class PlainPleaseApp extends ConsumerWidget {
  const PlainPleaseApp({super.key});

  static const Color accentViolet = Color(0xFF6D28D9);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'PlainPlease',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accent: accentViolet),
      darkTheme: AppTheme.dark(accent: accentViolet),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
