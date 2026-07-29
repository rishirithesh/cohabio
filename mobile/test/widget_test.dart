import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cohabio/main.dart';
import 'package:cohabio/core/providers/communities_provider.dart';
import 'package:cohabio/core/providers/housing_provider.dart';
import 'package:cohabio/core/providers/chat_provider.dart';
import 'package:cohabio/core/providers/events_provider.dart';
import 'package:cohabio/core/providers/roommates_provider.dart';
import 'package:cohabio/core/providers/notification_provider.dart';
import 'package:cohabio/core/providers/profile_provider.dart';

class MockCommunitiesNotifier extends CommunitiesNotifier {
  MockCommunitiesNotifier() : super() {
    state = const AsyncValue.data([]);
  }
  @override
  Future<void> fetchCommunities({String? category, String? city}) async {}
}

class MockHousingNotifier extends HousingNotifier {
  MockHousingNotifier() : super() {
    state = const AsyncValue.data([]);
  }
  @override
  Future<void> fetchProperties({String? city, String? roomType, double? priceMax}) async {}
}

class MockChatRoomsNotifier extends ChatRoomsNotifier {
  MockChatRoomsNotifier() : super() {
    state = const AsyncValue.data([]);
  }
  @override
  Future<void> fetchRooms() async {}
}

class MockEventsNotifier extends EventsNotifier {
  MockEventsNotifier() : super() {
    state = const AsyncValue.data([]);
  }
  @override
  Future<void> fetchEvents({String? communityId}) async {}
}

class MockRoommatesNotifier extends RoommatesNotifier {
  MockRoommatesNotifier() : super() {
    state = const AsyncValue.data([]);
  }
  @override
  Future<void> fetchRecommendations() async {}
}

class MockNotificationNotifier extends NotificationNotifier {
  MockNotificationNotifier() : super() {
    state = NotificationState(items: [], unreadCount: 0, isLoading: false);
  }
  @override
  Future<void> fetchNotifications() async {}
  @override
  Future<void> registerDeviceToken() async {}
}

class MockProfileNotifier extends ProfileNotifier {
  MockProfileNotifier() : super() {
    state = const AsyncValue.data({'full_name': 'Test User'});
  }
  @override
  Future<void> fetchProfile() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return null;
      },
    );
  });

  testWidgets('AppDashboardNavigator mounts cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          communitiesProvider.overrideWith((ref) => MockCommunitiesNotifier()),
          housingProvider.overrideWith((ref) => MockHousingNotifier()),
          chatRoomsProvider.overrideWith((ref) => MockChatRoomsNotifier()),
          eventsProvider.overrideWith((ref) => MockEventsNotifier()),
          roommatesProvider.overrideWith((ref) => MockRoommatesNotifier()),
          notificationProvider.overrideWith((ref) => MockNotificationNotifier()),
          profileProvider.overrideWith((ref) => MockProfileNotifier()),
        ],
        child: const MaterialApp(
          home: AppDashboardNavigator(),
        ),
      ),
    );
    expect(find.byType(AppDashboardNavigator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
  });
}
