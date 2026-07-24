import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/core/providers/auth_provider.dart';
import 'package:cohabio/features/auth/presentation/splash_screen.dart';
import 'package:cohabio/features/auth/presentation/auth_landing_screen.dart';
import 'package:cohabio/features/auth/presentation/login_screen.dart';
import 'package:cohabio/features/auth/presentation/signup_screen.dart';
import 'package:cohabio/features/auth/presentation/otp_verification_screen.dart';
import 'package:cohabio/features/auth/presentation/forgot_password_screen.dart';
import 'package:cohabio/features/profile/presentation/profile_onboarding_screen.dart';
import 'package:cohabio/main.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth-landing',
        builder: (context, state) => const AuthLandingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          final email = state.extra as String? ?? authState.pendingVerificationEmail ?? '';
          return OtpVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => ProfileOnboardingScreen(
          onComplete: () => context.go('/dashboard'),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const AppDashboardNavigator(),
      ),
    ],
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final loc = state.matchedLocation;

      // Allow splash screen to display without immediate redirection
      if (loc == '/splash') return null;

      final isUnauthRoute = loc == '/auth-landing' ||
          loc == '/login' ||
          loc == '/signup' ||
          loc == '/verify-otp' ||
          loc == '/forgot-password';

      if (!isAuth && !isUnauthRoute) {
        return '/auth-landing';
      }

      if (isAuth && isUnauthRoute) {
        return '/dashboard';
      }

      return null;
    },
  );
});
