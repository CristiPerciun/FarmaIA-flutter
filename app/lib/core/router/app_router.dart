import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/presentation/consents_screen.dart';
import '../../features/account/presentation/profile_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/catalog/presentation/catalog_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/style_guide/presentation/style_guide_screen.dart';
import '../../l10n/app_localizations.dart';

/// Route prefixes that require a signed-in user (§9.2). `/admin` additionally
/// requires a staff role, checked in the redirect below.
const _authPrefixes = ['/account', '/admin'];
const _staffPrefixes = ['/admin'];

bool _hasPrefix(String location, List<String> prefixes) =>
    prefixes.any((p) => location == p || location.startsWith('$p/'));

final appRouterProvider = Provider<GoRouter>((ref) {
  // A stable Listenable that pokes go_router whenever auth or the profile
  // (role) changes — so guards re-run on login, logout, session expiry (§9.2)
  // and role updates, without rebuilding the router itself.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateChangesProvider, (_, _) => refresh.value++);
  ref.listen(appUserProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      // Don't bounce while auth is still resolving (avoids a login flicker).
      if (authState.isLoading) return null;

      final loggedIn = authState.valueOrNull != null;
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';
      final needsAuth = _hasPrefix(location, _authPrefixes);
      final needsStaff = _hasPrefix(location, _staffPrefixes);

      // Guard protected routes: send to login, preserving where we came from.
      if (!loggedIn && needsAuth) {
        final from = Uri.encodeComponent(state.uri.toString());
        return '/login?from=$from';
      }

      // Signed-in users shouldn't sit on the login/registration pages.
      if (loggedIn && isAuthRoute) return '/profile';

      // Admin area is staff-only. While the profile is still loading, stay put
      // to avoid kicking a legitimate staff user out on a cold start.
      if (needsStaff) {
        final profile = ref.read(appUserProvider);
        final isStaff = profile.valueOrNull?.isStaff ?? false;
        if (!isStaff && !profile.isLoading) return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/catalog',
        name: 'catalog',
        builder: (context, state) => const CatalogScreen(),
      ),
      GoRoute(
        path: '/style-guide',
        name: 'styleGuide',
        builder: (context, state) => const StyleGuideScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) =>
            LoginScreen(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'consents',
            name: 'consents',
            builder: (context, state) => const ConsentsScreen(),
          ),
        ],
      ),
      // /account/consents is the guarded alias (auth-required prefix) used as a
      // session-expiry return path and for deep links.
      GoRoute(
        path: '/account/consents',
        name: 'accountConsents',
        builder: (context, state) => const ConsentsScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.notFound(state.uri.toString()),
        ),
      ),
    ),
  );
});
