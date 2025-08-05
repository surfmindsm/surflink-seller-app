import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/auto_match_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/common/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/campaign/campaign_list_screen.dart';
import 'screens/campaign/campaign_create_screen.dart';
import 'screens/matching/auto_match_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const SellerSurfLinkApp());
}

class SellerSurfLinkApp extends StatelessWidget {
  const SellerSurfLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AutoMatchProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: '셀러셀러 - 인플루언서 매칭 플랫폼',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

// GoRouter 설정
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
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
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/campaigns',
      builder: (context, state) => const CampaignListScreen(),
    ),
    GoRoute(
      path: '/auto-match',
      builder: (context, state) => const AutoMatchScreen(),
    ),
    GoRoute(
      path: '/campaign/create',
      builder: (context, state) => const CampaignCreateScreen(),
    ),
  ],
);
