import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_theme.dart';
import 'core/config/router.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const ProviderScope(child: BeakonApp()));
}

class BeakonApp extends ConsumerWidget {
  const BeakonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final accent = ref.watch(accentColorProvider);
    final sidebarBase = ref.watch(sidebarColorProvider);
    final cardBase = ref.watch(cardColorProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Beacøn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accent: accent, sidebarBase: sidebarBase),
      darkTheme: AppTheme.dark(
        accent: accent,
        sidebarBase: sidebarBase,
        cardBase: cardBase,
      ),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
