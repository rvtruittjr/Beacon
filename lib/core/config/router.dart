import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'design_tokens.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/onboarding/onboarding_screen.dart';
import '../../features/auth/ui/register_screen.dart';
import '../../features/asset_library/ui/asset_library_screen.dart';
import '../../features/brand_kit/ui/brand_kit_screen.dart';
import '../../features/brand_snapshot/ui/snapshot_screen.dart';
import '../../features/voice_tone/ui/voice_screen.dart';
import '../../features/audience/ui/audience_screen.dart';
import '../../features/content_archive/ui/archive_screen.dart';
import '../../features/sharing/ui/share_settings_screen.dart';
import '../../features/sharing/ui/password_gate_screen.dart';
import '../../features/sharing/ui/public_brand_kit_screen.dart';
import '../../features/settings/ui/settings_screen.dart';
import '../../features/settings/ui/subscription_screen.dart';
import '../../shared/widgets/platform_adaptive/adaptive_scaffold.dart';
import '../providers/app_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier(ref);

  return GoRouter(
    refreshListenable: authNotifier,
    initialLocation: ref.read(isAuthenticatedProvider) ? '/app/snapshot' : '/login',
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final isOnAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isOnOnboarding = state.matchedLocation == '/onboarding';
      final isPublicShare = state.matchedLocation.startsWith('/share/');

      // Public share routes bypass auth
      if (isPublicShare) return null;

      // Not authenticated — force to login (unless already on auth page)
      if (!isAuthenticated) {
        if (isOnAuthPage) return null;
        return '/login';
      }

      // Authenticated but on auth page — send to app
      if (isAuthenticated && isOnAuthPage) {
        return '/app/snapshot';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Public share routes (no auth required)
      GoRoute(
        path: '/share/:token',
        builder: (context, state) => PublicBrandKitScreen(
          shareToken: state.pathParameters['token']!,
        ),
      ),
      GoRoute(
        path: '/share/:token/gate',
        builder: (context, state) => PasswordGateScreen(
          shareToken: state.pathParameters['token']!,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AdaptiveScaffold(child: child),
        routes: [
          GoRoute(
            path: '/app/snapshot',
            pageBuilder: (context, state) =>
                _fadeSlide(state, const SnapshotScreen()),
          ),
          GoRoute(
            path: '/app/brand-kit',
            pageBuilder: (context, state) =>
                _fadeSlide(state, const BrandKitScreen()),
          ),
          GoRoute(
            path: '/app/library',
            pageBuilder: (context, state) =>
                _fadeSlide(state, const AssetLibraryScreen()),
          ),
          GoRoute(
            path: '/app/voice',
            pageBuilder: (context, state) =>
                _fadeSlide(state, const VoiceScreen()),
          ),
          GoRoute(
            path: '/app/audience',
            pageBuilder: (context, state) =>
                _fadeSlide(state, const AudienceScreen()),
          ),
          GoRoute(
            path: '/app/archive',
            pageBuilder: (context, state) =>
                _fadeSlide(state, const ArchiveScreen()),
          ),
          GoRoute(
            path: '/app/sharing',
            pageBuilder: (context, state) =>
                _fadeSlide(state, const ShareSettingsScreen()),
          ),
          GoRoute(
            path: '/app/settings',
            pageBuilder: (context, state) =>
                _fadeSlide(state, const SettingsScreen()),
          ),
          GoRoute(
            path: '/app/settings/subscription',
            pageBuilder: (context, state) =>
                _fadeSlide(state, const SubscriptionScreen()),
          ),
        ],
      ),
    ],
  );
});

/// 250ms fade + 8px slide-up transition for all app pages.
CustomTransitionPage<void> _fadeSlide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.normal,
    reverseTransitionDuration: AppDurations.fast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.01), // ~8px at typical screen height
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Listenable that notifies GoRouter when auth state changes.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this._ref) {
    _sub = _ref.listen(authStateProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
  late final ProviderSubscription _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
