# RentHive Installation Guide

Follow these steps to setup RentHive locally for your final-year project demonstration.

## Prerequisites
- Node.js (v16+)
- MongoDB (Local instance or Atlas Cluster)
- Flutter SDK (v3.19+)
- Android Studio / Android Emulator

## Backend Setup (Node.js + Express)
1. Navigate to the `backend` folder:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Create a `.env` file from the example:
   ```bash
   cp .env.example .env
   ```
4. Update the `.env` file with your MongoDB connection string (`MONGO_URI`) and a secure `JWT_SECRET`.
5. Seed the database (optional):
   ```bash
   npm run seed
   ```
6. Start the development server:
   ```bash
   npm run dev
   ```
   *The server should now be running on http://localhost:5000*

## Frontend Setup (Flutter)
1. Navigate to the root folder:
   ```bash
   cd ../
   ```
2. Get Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Update Base URL (if necessary):
   - By default, the `api_client.dart` connects to `http://10.0.2.2:5000/api` which is the localhost alias for the Android Emulator.
   - If running on a physical Android device, change this IP to your machine's local IPv4 address (e.g., `192.168.1.5:5000`).
   - If running on iOS Simulator, change to `127.0.0.1:5000`.

4. Run the app:
   ```bash
   flutter run
   ```

## Production Configurations (Important for Final Demo)
To successfully demonstrate features like Maps and Push Notifications, you MUST register the application on the respective developer portals:
- **Google Cloud Console:** Enable the "Maps SDK for Android" and copy the API key into `android/app/src/main/AndroidManifest.xml`.
- **Firebase Console:** Create a new project, add an Android app with the package name `com.example.renthive`, and download the `google-services.json` file to `android/app/`.
- **Razorpay Dashboard:** Generate a Test API Key and insert it into `booking_summary_screen.dart`.
