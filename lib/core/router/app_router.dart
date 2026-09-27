import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/main/screens/main_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/listings/screens/my_listings_screen.dart';
import '../../features/listings/screens/add_edit_listing_screen.dart';
import '../../features/item_details/screens/item_details_screen.dart';
import '../../features/bookings/screens/booking_calendar_screen.dart';
import '../../features/bookings/screens/booking_summary_screen.dart';
import '../../features/bookings/screens/booking_confirmation_screen.dart';
import '../../features/bookings/screens/my_bookings_screen.dart';
import '../../features/bookings/screens/booking_details_screen.dart';
import '../../features/engagement/screens/wishlist_screen.dart';
import '../../features/engagement/screens/conversations_screen.dart';
import '../../features/engagement/screens/chat_screen.dart';
import '../../features/engagement/screens/notifications_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/public_profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/reviews_list_screen.dart';
import '../../features/profile/screens/write_review_screen.dart';
import '../../features/owner/screens/owner_hub_screen.dart';
import '../../features/owner/screens/owner_dashboard_screen.dart';
import '../../features/owner/screens/owner_bookings_screen.dart';
import '../../features/owner/screens/owner_earnings_screen.dart';
import '../../features/owner/screens/owner_calendar_screen.dart';
import '../../features/owner/screens/owner_analytics_screen.dart';
import '../../features/owner/screens/owner_reports_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/common/screens/global_error_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  static const String home = '/home';
  static const String search = '/search';
  static const String myListings = '/my-listings';
  static const String addListing = '/add-listing';
  static const String bookings = '/bookings';
  static const String profile = '/profile';
  
  static const String itemDetails = '/item-details';
  static const String bookingCalendar = '/booking-calendar';
  static const String bookingSummary = '/booking-summary';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String bookingDetails = '/booking-details';

  static const String wishlist = '/wishlist';
  static const String inbox = '/inbox';
  static const String chat = '/chat';
  static const String notifications = '/notifications';

  static const String editProfile = '/edit-profile';
  static const String publicProfile = '/public-profile';
  static const String settings = '/settings';
  static const String writeReview = '/write-review';
  static const String reviewsList = '/reviews-list';

  static const String ownerHub = '/owner-hub';
  static const String ownerAnalytics = '/owner-analytics';
  static const String ownerReports = '/owner-reports';

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final _shellNavigatorSearchKey = GlobalKey<NavigatorState>(debugLabel: 'shellSearch');
  static final _shellNavigatorAddKey = GlobalKey<NavigatorState>(debugLabel: 'shellAdd');
  static final _shellNavigatorBookingsKey = GlobalKey<NavigatorState>(debugLabel: 'shellBookings');
  static final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  // Owner shell keys
  static final _shellNavigatorOwnerDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'shellOwnerDashboard');
  static final _shellNavigatorOwnerBookingsKey = GlobalKey<NavigatorState>(debugLabel: 'shellOwnerBookings');
  static final _shellNavigatorOwnerEarningsKey = GlobalKey<NavigatorState>(debugLabel: 'shellOwnerEarnings');
  static final _shellNavigatorOwnerCalendarKey = GlobalKey<NavigatorState>(debugLabel: 'shellOwnerCalendar');

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: splash,
    errorBuilder: (context, state) => GlobalErrorScreen(error: state.error),
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: addListing,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return AddEditListingScreen(listingId: id);
        },
      ),
      GoRoute(
        path: itemDetails,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final itemId = state.uri.queryParameters['itemId']!;
          return ItemDetailsScreen(itemId: itemId);
        },
      ),
      GoRoute(
        path: bookingCalendar,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final itemId = state.uri.queryParameters['itemId']!;
          return BookingCalendarScreen(itemId: itemId);
        },
      ),
      GoRoute(
        path: bookingSummary,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final itemId = state.uri.queryParameters['itemId']!;
          final start = DateTime.parse(state.uri.queryParameters['start']!);
          final end = DateTime.parse(state.uri.queryParameters['end']!);
          return BookingSummaryScreen(itemId: itemId, startDate: start, endDate: end);
        },
      ),
      GoRoute(
        path: bookingConfirmation,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final bookingId = state.uri.queryParameters['bookingId']!;
          return BookingConfirmationScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: bookingDetails,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id']!;
          return BookingDetailsScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: wishlist,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: inbox,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: chat,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id']!;
          final name = state.uri.queryParameters['name']!;
          return ChatScreen(conversationId: id, otherUserName: name);
        },
      ),
      GoRoute(
        path: editProfile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: publicProfile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id']!;
          return PublicProfileScreen(userId: id);
        },
      ),
      GoRoute(
        path: writeReview,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final targetId = state.uri.queryParameters['targetId']!;
          return WriteReviewScreen(targetId: targetId);
        },
      ),
      GoRoute(
        path: reviewsList,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final targetId = state.uri.queryParameters['targetId']!;
          return ReviewsListScreen(targetId: targetId);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSearchKey,
            routes: [
              GoRoute(
                path: search,
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAddKey,
            routes: [
              GoRoute(
                path: myListings,
                builder: (context, state) => const MyListingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorBookingsKey,
            routes: [
              GoRoute(
                path: bookings,
                builder: (context, state) => const MyBookingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return OwnerHubScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorOwnerDashboardKey,
            routes: [
              GoRoute(
                path: ownerHub,
                builder: (context, state) => const OwnerDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorOwnerBookingsKey,
            routes: [
              GoRoute(
                path: '/owner-bookings',
                builder: (context, state) => const OwnerBookingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorOwnerEarningsKey,
            routes: [
              GoRoute(
                path: '/owner-earnings',
                builder: (context, state) => const OwnerEarningsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorOwnerCalendarKey,
            routes: [
              GoRoute(
                path: '/owner-calendar',
                builder: (context, state) => const OwnerCalendarScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: ownerAnalytics,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OwnerAnalyticsScreen(),
      ),
      GoRoute(
        path: ownerReports,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OwnerReportsScreen(),
      ),
    ],
  );
}
