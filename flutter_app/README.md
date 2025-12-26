# TaskSense Flutter App

A beautiful, Material Design 3 mobile application for smart task management with auto-classification.

## Features

- **Task Dashboard**: View all tasks with summary cards
- **Auto-Classification**: Tasks are automatically categorized and prioritized
- **Search & Filter**: Find tasks quickly with search and filters
- **Pull to Refresh**: Update task list with a simple pull gesture
- **Create/Edit Tasks**: Intuitive forms with validation
- **Manual Override**: Option to manually set category and priority
- **Offline Indicator**: Know when you're offline
- **Material Design 3**: Modern, beautiful UI

## Screenshots

*(Screenshots will be added after testing)*

## Setup

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android device or emulator

### Installation

1. **Navigate to the Flutter app directory**:
```bash
cd flutter_app
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Configure API endpoint**:

Edit `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'https://your-backend.onrender.com/api';
```

4. **Run the app**:
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## Project Structure

```
lib/
├── config/
│   └── api_config.dart         # API configuration
├── models/
│   └── task_model.dart         # Data models
├── providers/
│   └── task_provider.dart      # State management (Riverpod)
├── screens/
│   ├── dashboard_screen.dart   # Main dashboard
│   └── task_form_screen.dart   # Create/edit task form
├── services/
│   └── api_service.dart        # API client (Dio)
├── widgets/
│   └── task_card.dart          # Task card widget
└── main.dart                   # App entry point
```

## Dependencies

- **flutter_riverpod**: State management
- **dio**: HTTP client
- **intl**: Date formatting
- **connectivity_plus**: Network status checking

## Building for Production

### Android

```bash
flutter build apk --release
```

The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

### iOS (macOS only)

```bash
flutter build ios --release
```

## Testing

Run the app with:
```bash
flutter run
```

Make sure the backend API is running and accessible.

## Troubleshooting

### Connection Issues

- Verify the `baseUrl` in `api_config.dart`
- Check if the backend API is running
- For Android emulator, use `http://10.0.2.2:3000/api` instead of `localhost`
- For iOS simulator, use `http://localhost:3000/api`

### Build Errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Features in Detail

### Dashboard
- Summary cards showing task counts by status
- Search bar for quick task lookup
- Filter by status, category, and priority
- Pull-to-refresh for updating data
- Empty state with helpful message

### Task Card
- Displays title, description, category, and priority
- Shows due date and assigned person
- Quick status change button
- Color-coded categories and priorities
- Tap to view/edit details

### Task Form
- Title and description fields
- Due date and time picker
- Assigned to field
- Auto-classification by default
- Manual override option
- Status selection (for editing)
- Delete button (for editing)

## License

MIT License
