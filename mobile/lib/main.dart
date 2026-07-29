import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/app/theme/cohabio_theme.dart';
import 'package:cohabio/app/router.dart';
import 'package:cohabio/features/communities/presentation/communities_feed_screen.dart';
import 'package:cohabio/features/roommate_matching/presentation/roommate_swipe_screen.dart';
import 'package:cohabio/features/housing/presentation/housing_screen.dart';
import 'package:cohabio/features/ai_assistant/presentation/ai_relocation_screen.dart';
import 'package:cohabio/features/events/presentation/events_screen.dart';
import 'package:cohabio/features/chat/presentation/chat_list_screen.dart';
import 'package:cohabio/features/notifications/presentation/notifications_screen.dart';
import 'package:cohabio/features/profile/presentation/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CohabioApp()));
}

class CohabioApp extends ConsumerWidget {
  const CohabioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Cohabio',
      debugShowCheckedModeBanner: false,
      theme: CohabioTheme.lightTheme,
      darkTheme: CohabioTheme.darkTheme,
      themeMode: ThemeMode.dark, // Sleek dark mode design as primary
      routerConfig: router,
    );
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
    const HousingScreen(),
    const AiRelocationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.handshake, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Cohabio',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Chats',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChatListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outline),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: const Color(0xFF1E293B),
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: const Color(0xFF94A3B8),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Communities',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.style_outlined),
              activeIcon: Icon(Icons.style),
              label: 'Matches',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_work_outlined),
              activeIcon: Icon(Icons.home_work),
              label: 'Housing',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome),
              label: 'AI Guide',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
