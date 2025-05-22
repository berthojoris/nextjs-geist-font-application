# Survey App

A Flutter application for conducting surveys at events, with support for offline data collection and online synchronization.

## Features

- Responsive design for both tablets and phones
- Multiple question types:
  - Text input for open-ended responses
  - Radio buttons for single-choice questions
  - Checkboxes for multiple-choice questions
  - Dropdown menus for selection questions
- Local data storage using Hive database
- Online synchronization with Supabase backend
- Admin panel with sync status and response management
- Progress tracking and navigation between questions
- Material Design 3 UI components

## Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- A Supabase account for backend services

## Setup Instructions

1. **Flutter Setup**
   ```bash
   # Verify Flutter installation
   flutter doctor
   
   # Get dependencies
   flutter pub get
   
   # Generate Hive adapters
   flutter pub run build_runner build
   ```

2. **Supabase Configuration**
   - Create a new project at [Supabase](https://supabase.com)
   - Create the survey_responses table:
     ```sql
     create table survey_responses (
       id uuid primary key,
       question_id text not null,
       answer jsonb not null,
       timestamp timestamp with time zone not null
     );
     ```
   - Copy your project URL and anon key
   - Update `lib/services/supabase_service.dart` with your credentials:
     ```dart
     static const String supabaseUrl = 'YOUR_SUPABASE_URL';
     static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
     ```

3. **Run the App**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point and theme configuration
├── models/
│   ├── question.dart        # Question data model
│   └── survey_response.dart # Survey response data model
├── screens/
│   ├── survey/
│   │   ├── survey_screen.dart     # Main survey interface
│   │   └── question_widget.dart   # Question display widget
│   └── admin/
│       └── admin_screen.dart      # Admin panel and sync management
└── services/
    ├── hive_service.dart    # Local database operations
    └── supabase_service.dart# Online sync operations
```

## Sample Questions

The app comes with 10 pre-configured questions covering different types:
1. Event organization satisfaction (Radio)
2. Favorite aspects (Checkbox)
3. Additional feedback (Text)
4. Event recommendation likelihood (Radio)
5. Preferred session format (Dropdown)
6. Future topics interest (Checkbox)
7. Presentation quality rating (Radio)
8. Venue rating (Radio)
9. Improvement suggestions (Text)
10. Preferred timing (Dropdown)

To modify questions, edit the `_initializeSampleQuestions` method in `lib/services/hive_service.dart`.

## Features Implementation

### Local Storage
- Uses Hive for efficient local data storage
- Automatic initialization of sample questions
- Persistent storage of survey responses

### Responsive Design
- Adapts to both tablet and phone layouts
- Uses flutter_screenutil for consistent sizing
- Material Design 3 components and theming

### Survey Navigation
- Progress indicator shows completion status
- Next/Previous navigation buttons
- Question counter display

### Admin Features
- View all responses with sync status
- Manual sync trigger for uploading responses
- Visual indicators for sync status
- Error handling and retry mechanisms

## Dependencies

```yaml
dependencies:
  flutter_screenutil: ^5.8.4  # Responsive UI
  hive: ^2.2.3               # Local database
  hive_flutter: ^1.1.0       # Hive Flutter integration
  supabase_flutter: ^1.10.3  # Backend service
  provider: ^6.0.5          # State management
  uuid: ^3.0.7              # Unique ID generation
```

## Error Handling

- Offline capability with local storage
- Sync retry mechanism
- User feedback for sync status
- Error messages for failed operations

## Performance Considerations

- Efficient local storage with Hive
- Batch synchronization of responses
- Lazy loading of questions
- Optimized UI rendering

## Security

- Secure data storage with Hive
- Supabase authentication
- Input validation
- Error handling

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
