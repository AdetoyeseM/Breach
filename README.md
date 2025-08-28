# Breach App

A Flutter mobile application for staying informed about security news and real-time threat intelligence. This app provides users with a personalized experience to track cybersecurity events and read relevant articles.

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

### 📱 Mobile-First Design
- Clean, modern UI adapted for mobile
- Bottom navigation for easy access
- Responsive design with Material 3

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
├── models/           # Data models with JSON serialization
├── providers/        # Riverpod state management
├── screens/          # UI screens and navigation
│   ├── auth/        # Authentication screens
│   └── home/        # Main app screens
│       └── tabs/    # Bottom navigation tabs
├── services/         # API and WebSocket services
└── main.dart        # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
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

### Building for Production

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

## API Integration

The app connects to the Breach backend API:

- **Base URL**: `https://breach-api.qa.mvm-tech.xyz`
- **WebSocket**: `wss://breach-api-ws.qa.mvm-tech.xyz`

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

This project is part of the MVM Mobile Engineer Take Home Test.
