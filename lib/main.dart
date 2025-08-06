import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/auto_match_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/contract_provider.dart';
import 'providers/review_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/search_filter_provider.dart';
import 'models/review_model.dart';
import 'models/search_filter_model.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/common/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/campaign/campaign_list_screen.dart';
import 'screens/campaign/campaign_create_screen.dart';
import 'screens/matching/auto_match_screen.dart';
import './screens/chat/chat_list_screen.dart';
import './screens/chat/chat_screen.dart';
import './screens/contract/contract_list_screen.dart';
import './screens/contract/contract_create_screen.dart';
import './screens/payment/payment_screen.dart';
import './screens/review/review_write_screen.dart';
import './screens/review/review_list_screen.dart';
import './screens/notification/notification_list_screen.dart';
import './screens/search/advanced_search_screen.dart';
import './screens/search/filter_settings_screen.dart';
import './screens/search/search_results_screen.dart';
import './screens/settings/security_settings_screen.dart';
import './screens/admin/admin_dashboard_screen.dart';
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
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ContractProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SearchFilterProvider()),
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
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatListScreen(),
    ),
    GoRoute(
      path: '/chat/:chatId',
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        return ChatScreen(roomId: chatId);
      },
    ),
    GoRoute(
      path: '/contracts',
      builder: (context, state) => const ContractListScreen(),
    ),
    GoRoute(
      path: '/contract/create',
      builder: (context, state) {
        final campaignId = state.uri.queryParameters['campaignId'] ?? '';
        final campaignName = state.uri.queryParameters['campaignName'] ?? '';
        final influencerId = state.uri.queryParameters['influencerId'] ?? '';
        final influencerName = state.uri.queryParameters['influencerName'] ?? '';
        return ContractCreateScreen(
          campaignId: campaignId,
          campaignName: campaignName,
          influencerId: influencerId,
          influencerName: influencerName,
        );
      },
    ),
    GoRoute(
      path: '/payment/:contractId',
      builder: (context, state) {
        final contractId = state.pathParameters['contractId']!;
        return PaymentScreen(contractId: contractId);
      },
    ),
    // 리뷰 관련 라우트
    GoRoute(
      path: '/review/list',
      builder: (context, state) => const ReviewListScreen(),
    ),
    GoRoute(
      path: '/review/write',
      builder: (context, state) {
        final contractId = state.uri.queryParameters['contractId'] ?? '';
        final campaignName = state.uri.queryParameters['campaignName'] ?? '';
        final partnerId = state.uri.queryParameters['partnerId'] ?? '';
        final partnerName = state.uri.queryParameters['partnerName'] ?? '';
        final reviewTypeStr = state.uri.queryParameters['reviewType'] ?? 'influencer';
        final existingReviewId = state.uri.queryParameters['existingReviewId'];
        
        return ReviewWriteScreen(
          contractId: contractId,
          campaignName: campaignName,
          partnerId: partnerId,
          partnerName: partnerName,
          reviewType: reviewTypeStr == 'seller' ? ReviewType.sellerToInfluencer : ReviewType.influencerToSeller,
          existingReviewId: existingReviewId,
        );
      },
    ),
    // 알림 관련 라우트
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationListScreen(),
    ),
    // 검색 관련 라우트
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final targetTypeStr = state.uri.queryParameters['targetType'] ?? 'campaign';
        final initialKeyword = state.uri.queryParameters['keyword'];
        final targetType = SearchTargetType.values.firstWhere(
          (type) => type.name == targetTypeStr,
          orElse: () => SearchTargetType.campaign,
        );
        return AdvancedSearchScreen(
          targetType: targetType,
          initialKeyword: initialKeyword,
        );
      },
    ),
    GoRoute(
      path: '/search/filter-settings',
      builder: (context, state) {
        final targetTypeStr = state.uri.queryParameters['targetType'] ?? 'campaign';
        final targetType = SearchTargetType.values.firstWhere(
          (type) => type.name == targetTypeStr,
          orElse: () => SearchTargetType.campaign,
        );
        return FilterSettingsScreen(targetType: targetType);
      },
    ),
    GoRoute(
      path: '/search/results',
      builder: (context, state) {
        final targetTypeStr = state.uri.queryParameters['targetType'] ?? 'campaign';
        final targetType = SearchTargetType.values.firstWhere(
          (type) => type.name == targetTypeStr,
          orElse: () => SearchTargetType.campaign,
        );
        return SearchResultsScreen(targetType: targetType);
      },
    ),
    // 설정 관련 라우트
    GoRoute(
      path: '/security-settings',
      builder: (context, state) => const SecuritySettingsScreen(),
    ),
    // 관리자 관련 라우트
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
);
