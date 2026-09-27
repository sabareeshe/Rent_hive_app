# RentHive - Premium Rental Booking App

RentHive is a comprehensive, production-ready rental marketplace application built with Flutter, Riverpod, GoRouter, and a Node.js/Express backend. It allows users to rent and lend items seamlessly, featuring a secure payment flow via Razorpay, Google Maps integration for pickup locations, and Firebase Cloud Messaging for real-time notifications.

## Features

- **Clean Architecture:** Domain, Data, and Presentation layers separated for scalability.
- **State Management:** Riverpod 2.0 with AsyncNotifier.
- **Routing:** GoRouter with deep-linking support and nested shell routes.
- **Authentication:** JWT-based secure authentication stored safely via `flutter_secure_storage`.
- **Offline First:** Profile and Wishlist data cached via `shared_preferences`.
- **Payments:** Razorpay gateway integration for Security Deposits and Rental Fees.
- **Maps:** Google Maps integration for exact item pickup locations.
- **Push Notifications:** Firebase Cloud Messaging (FCM) integration.
- **Security:** Jailbreak/Root detection on startup.

## Project Structure

```
lib/
├── core/
│   ├── network/ (Dio configs, Interceptors, Error handling)
│   ├── router/ (GoRouter configuration)
│   └── theme/ (Material 3 Theme)
├── features/
│   ├── auth/ (Login, Register, Splash)
│   ├── bookings/ (Calendar, Summary, History)
│   ├── engagement/ (Wishlist, Chat, Notifications)
│   ├── home/ (Discover, Search)
│   ├── item_details/ (Item info, Google Map marker)
│   ├── listings/ (My Listings, Add Listing)
│   ├── owner/ (Dashboard, Earnings, Analytics)
│   └── profile/ (User Profile, Settings, Reviews)
└── main.dart
```

## Setup & API Keys

Before building for release, ensure you have placed your API keys in the appropriate locations:
1. **Google Maps API Key:** Place in `android/app/src/main/AndroidManifest.xml` inside `<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_KEY"/>`.
2. **Firebase configuration:** Download `google-services.json` from the Firebase console and place it in `android/app/`.
3. **Razorpay Key:** Update the Razorpay key in `lib/features/bookings/screens/booking_summary_screen.dart`.

## Compilation

To generate the launcher icons and splash screens:
```bash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

To build the release APK for Android:
```bash
flutter build apk --release
```
