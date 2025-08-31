import 'package:flutter/material.dart';
import '../presentation/account_connections/account_connections.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/content_calendar/content_calendar.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/user_profile_settings/user_profile_settings.dart';
import '../presentation/post_creation/post_creation.dart';
import '../presentation/social_media_dashboard/social_media_dashboard.dart';
import '../presentation/messages_inbox/messages_inbox.dart';
import '../presentation/analytics_dashboard/analytics_dashboard.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String accountConnections = '/account-connections';
  static const String splash = '/splash-screen';
  static const String contentCalendar = '/content-calendar';
  static const String login = '/login-screen';
  static const String userProfileSettings = '/user-profile-settings';
  static const String postCreation = '/post-creation';
  static const String socialMediaDashboard = '/social-media-dashboard';
  static const String messagesInbox = '/messages-inbox';
  static const String analyticsDashboard = '/analytics-dashboard';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    accountConnections: (context) => const AccountConnections(),
    splash: (context) => const SplashScreen(),
    contentCalendar: (context) => const ContentCalendar(),
    login: (context) => const LoginScreen(),
    userProfileSettings: (context) => const UserProfileSettings(),
    postCreation: (context) => const PostCreation(),
    socialMediaDashboard: (context) => const SocialMediaDashboard(),
    messagesInbox: (context) => const MessagesInbox(),
    analyticsDashboard: (context) => const AnalyticsDashboard(),
    // TODO: Add your other routes here
  };
}
