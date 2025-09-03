# Breach App

A Flutter mobile application for staying informed about security news and real-time threat intelligence. This app provides users with a personalized experience to track events and read relevant articles.


## Getting Started

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. Clone the repository:
```bash
git clone <https://github.com/AdetoyeseM/Breach.git>
cd breach_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```



## 🚀 Building and Deployment

### Automated Build Scripts

We've provided comprehensive build scripts to streamline your development workflow:

#### Mobile Build Script (`mobile_build.sh`)

The main script for building Android and iOS apps with advanced options:

```bash
# Make script executable
chmod +x mobile_build.sh

# Build for both platforms (release)
./mobile_build.sh

# Build only Android
./mobile_build.sh --android-only

# Build only iOS
./mobile_build.sh --ios-only 

# Build profile version
./mobile_build.sh --release 
```

#### Script Features

- **Platform Selection**: Build for Android, iOS, or both
- **Build Types**: Debug, Release, Profile
- **Version Control**: Custom version and build numbers
- **Clean Builds**: Option to clean before building
- **Test Integration**: Runs tests before building (can be skipped)
- **Error Handling**: Comprehensive error checking and reporting
- **Colored Output**: Easy-to-read colored terminal output 

### Manual Build Commands

#### Android Builds

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Profile APK
flutter build apk --profile

# Split APKs by architecture (recommended for Play Store)
flutter build apk --split-per-abi --release

# Android App Bundle (AAB) - Recommended for Play Store
flutter build appbundle --release

# Build with custom version
flutter build apk --release --build-name=1.2.3 --build-number=123
```

#### iOS Builds

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release

# Profile build
flutter build ios --profile

# Build with custom version
flutter build ios --release --build-name=1.2.3 --build-number=123

# Archive for App Store (requires Xcode)
flutter build ios --release --no-codesign
```

### Build Output Locations

- **Android APK**: `build/app/outputs/flutter-apk/`
- **Android AAB**: `build/app/outputs/bundle/`
- **iOS**: `build/ios/`


## Features

### 🔐 Authentication
- User registration and login with email/password
- Secure token-based authentication
- Persistent login sessions

### 📰 Posts & Articles
- Browse security-related blog posts
- Filter posts by categories
- Rich content display with images
- Pull-to-refresh functionality

### 🎯 User Interests
- Select topics of interest during onboarding
- Personalized content recommendations
- Manage interests from profile

### ⚡ Real-time Events
- Live WebSocket connection for real-time events
- Display of the 5 most recent security events
- Event categorization and timestamps 

## Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **HTTP Client**: http package
- **WebSocket**: web_socket_channel
- **Local Storage**: shared_preferences
- **UI Components**: Material Design 3

## Project Structure

```
lib/
├── constant/         # Assets,themedata,colors etc
├── models/           # Data models with JSON serialization
├── providers/        # Riverpod state management
├── screens/          # UI screens and navigation
│   ├── auth/         # Authentication screens
│   └── home/         # Main app screens
│       └── tabs/     # Bottom navigation tabs
├── services/         # API and WebSocket services
└── main.dart         # App entry point
```


## API Integration

The app connects to the Breach backend API:

- **Base URL**: `https://breach-***************.xyz`
- **WebSocket**: `wss://breach-**********************.xyz`

### Available Endpoints

- `POST /auth/register` - User registration
- `POST /auth/login` - User authentication
- `GET /posts` - Fetch blog posts
- `GET /categories` - Fetch post categories
- `POST /user/interests` - Save user interests

## Implementation Details

### State Management
- Uses Riverpod for reactive state management
- Separate providers for authentication, posts, and events
- Automatic state persistence for user sessions

### Error Handling
- Comprehensive error handling for API calls
- User-friendly error messages
- Retry mechanisms for failed requests

### Performance
- Efficient list rendering with ListView.builder
- Image caching for better performance
- Optimized WebSocket connection management

## Features Implemented

✅ User registration and login  
✅ Blog posts listing with category filtering  
✅ User interests management  
✅ Real-time events via WebSocket  
✅ Mobile-optimized UI design  
✅ Clean architecture with separation of concerns  
✅ Error handling and loading states  
✅ Pull-to-refresh functionality  

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is part of the MVM Mobile Engineer Take Home Test by MATTHEW ADETOYESE.
