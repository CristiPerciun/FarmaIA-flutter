import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_env.dart';
import 'core/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/offline_banner.dart';
import 'features/compliance/presentation/cookie_banner.dart';
import 'l10n/app_localizations.dart';

class BaganzaApp extends ConsumerWidget {
  const BaganzaApp({super.key, required this.env});

  final AppEnv env;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Farma Smart',
      debugShowCheckedModeBanner: env.isDev,
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      // App-wide overlay for the cookie banner (§1.4) — it renders above every
      // route and collapses to nothing once the user decides.
      builder: (context, child) => Stack(
        children: [
          child ?? const SizedBox.shrink(),
          // Offline banner pinned to the top (§9.1).
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: const OfflineBanner(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: const CookieBanner(),
            ),
          ),
        ],
      ),
    );
  }
}
