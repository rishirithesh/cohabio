import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/app/theme/cohabio_theme.dart';
import 'package:cohabio/features/auth/presentation/login_screen.dart';
import 'package:cohabio/features/profile/presentation/profile_onboarding_screen.dart';
import 'package:cohabio/features/communities/presentation/communities_feed_screen.dart';
import 'package:cohabio/features/roommate_matching/presentation/roommate_swipe_screen.dart';
import 'package:cohabio/features/ai_assistant/presentation/ai_relocation_screen.dart';
import 'package:cohabio/features/notifications/presentation/notifications_screen.dart';

void main() {
  runApp(const ProviderScope(child: CohabioApp()));
}

class CohabioApp extends StatelessWidget {
  const CohabioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cohabio',
      debugShowCheckedModeBanner: false,
      theme: CohabioTheme.lightTheme,
      darkTheme: CohabioTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const MainAppFlow(),
    );
  }
}

class MainAppFlow extends StatefulWidget {
  const MainAppFlow({Key? key}) : super(key: key);

  @override
  State<MainAppFlow> createState() => _MainAppFlowState();
}

class _MainAppFlowState extends State<MainAppFlow> {
  String _currentStep = "login"; // login, onboarding, home

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case "login":
        return LoginScreen(
          onLoginSuccess: () => setState(() => _currentStep = "onboarding"),
        );
      case "onboarding":
        return ProfileOnboardingScreen(
          onComplete: () => setState(() => _currentStep = "home"),
        );
      case "home":
        return const AppDashboardNavigator();
      default:
        return LoginScreen(onLoginSuccess: () {});
    }
  }
}

class AppDashboardNavigator extends StatefulWidget {
  const AppDashboardNavigator({Key? key}) : super(key: key);

  @override
  State<AppDashboardNavigator> createState() => _AppDashboardNavigatorState();
}

class _AppDashboardNavigatorState extends State<AppDashboardNavigator> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const CommunitiesFeedScreen(),
    const RoommateSwipeScreen(),
    const AiRelocationScreen(),
    const NotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: CohabioTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Communities',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assistant_outlined),
            activeIcon: Icon(Icons.assistant),
            label: 'AI Guide',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}
