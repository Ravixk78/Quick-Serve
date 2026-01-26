# QuickServe - Modern Service Booking App

QuickServe is a modern, production-ready Flutter mobile application for booking professional services. Built with Flutter and Supabase, it provides a seamless experience for both customers and service providers.

## ✨ Features

### Customer Features
- 📱 Browse services by category
- 🔍 Search and filter services
- 📅 Book services with date/time selection
- 📊 Track booking status (pending, confirmed, completed)
- 🔔 Receive notifications
- 👤 Manage profile and settings
- 🌓 Light and Dark mode support

### Service Provider Features
- 💼 Manage service offerings
- 📋 View and manage bookings
- 👥 Customer management
- 📈 Track service ratings

### Technical Features
- 🔐 Secure authentication with Supabase
- 🎨 Modern, card-based UI design
- ✅ Form validation
- 🔄 Real-time data sync
- 📱 Responsive design for Android and iOS
- 🎭 Smooth animations and transitions
- ⚡ Clean architecture with proper folder structure

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Backend**: Supabase (Auth + Database)
- **State Management**: Provider
- **Navigation**: Named routes
- **UI Components**: Material Design 3
- **Additional Packages**:
  - supabase_flutter
  - provider
  - smooth_page_indicator
  - intl (date formatting)
  - And more...

## 📂 Project Structure

```
lib/
├── config/
│   └── supabase_config.dart       # Supabase configuration
├── models/
│   ├── user_model.dart            # User data model
│   ├── service_model.dart         # Service & category models
│   └── booking_model.dart         # Booking data model
├── services/
│   ├── auth_service.dart          # Authentication logic
│   ├── service_service.dart       # Service management
│   └── booking_service.dart       # Booking management
├── providers/
│   ├── auth_provider.dart         # Auth state management
│   └── theme_provider.dart        # Theme state management
├── screens/
│   ├── splash/                    # Splash screen
│   ├── onboarding/                # Onboarding screens
│   ├── auth/                      # Login & Signup
│   ├── home/                      # Home screen
│   ├── services/                  # Service list & details
│   ├── bookings/                  # Booking & my bookings
│   ├── notifications/             # Notifications
│   ├── profile/                   # User profile
│   └── settings/                  # App settings
├── widgets/
│   ├── custom_button.dart         # Reusable button widget
│   └── custom_text_field.dart     # Reusable text field
├── theme/
│   └── app_theme.dart             # App theme configuration
├── utils/
│   ├── validators.dart            # Form validators
│   └── datetime_helper.dart       # Date/time utilities
└── main.dart                      # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   cd "c:\Projects\Quick serve\quick_serve"
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Supabase**
   - Create a new project at [supabase.com](https://supabase.com)
   - Go to Settings > API to get your URL and anon key
   - Update `lib/config/supabase_config.dart` with your credentials:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

4. **Set up database**
   - Go to your Supabase project
   - Navigate to SQL Editor
   - Run the SQL script from `supabase_schema.sql`

5. **Run the app**
   ```bash
   flutter run
   ```

## 🗄️ Database Schema

The app uses the following Supabase tables:

### users
- id (UUID, Primary Key)
- email (Text)
- full_name (Text)
- role (Text) - 'customer' or 'service_provider'
- phone_number (Text, nullable)
- profile_image (Text, nullable)
- created_at (Timestamp)

### categories
- id (UUID, Primary Key)
- name (Text)
- icon (Text)
- description (Text)
- created_at (Timestamp)

### services
- id (UUID, Primary Key)
- name (Text)
- description (Text)
- price (Numeric)
- category_id (UUID, Foreign Key)
- provider_id (UUID, Foreign Key)
- image_url (Text, nullable)
- rating (Numeric, nullable)
- review_count (Integer, nullable)
- duration (Text, nullable)
- provider_name (Text)
- is_active (Boolean)
- created_at (Timestamp)

### bookings
- id (UUID, Primary Key)
- service_id (UUID, Foreign Key)
- customer_id (UUID, Foreign Key)
- provider_id (UUID, Foreign Key)
- status (Text) - 'pending', 'confirmed', 'completed', 'cancelled'
- booking_date (Timestamp)
- total_amount (Numeric)
- notes (Text, nullable)
- created_at (Timestamp)

## 🎨 UI/UX Features

### Design Principles
- Modern, minimal interface
- Card-based layouts
- Rounded corners and soft shadows
- Smooth animations and transitions
- Consistent color scheme
- Intuitive navigation

### Color Scheme
- Primary: Purple (#6C63FF)
- Secondary: Pink (#FF6584)
- Accent: Green (#4CAF50)
- Success: Green (#48BB78)
- Warning: Orange (#ED8936)
- Error: Red (#F56565)

### Theme Support
- Light mode (default)
- Dark mode
- System default (follows device settings)

## 📱 Screens Overview

1. **Splash Screen** - Animated logo with auto-navigation
2. **Onboarding** - 3-page introduction with smooth indicators
3. **Login** - Email/password authentication
4. **Signup** - User registration with role selection
5. **Home** - Service categories and featured services
6. **Service List** - Browse all services with filters
7. **Service Details** - Detailed service information
8. **Booking** - Date/time selection and confirmation
9. **My Bookings** - Tabbed view of booking history
10. **Notifications** - Real-time notifications
11. **Profile** - User information and settings
12. **Settings** - Theme, notifications, and account settings

## 🔐 Authentication Flow

1. User signs up with email, password, name, and role
2. User data is stored in Supabase Auth
3. User profile is created in the users table
4. On login, user credentials are verified
5. User session is maintained automatically
6. Logout clears session and redirects to login

## 📝 Environment Variables

Before running the app, make sure to update:

- `lib/config/supabase_config.dart` with your Supabase credentials

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📦 Building

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

This is a demo project. Feel free to fork and modify as needed.

## 📄 License

This project is open source and available under the MIT License.

## 📞 Support

For issues or questions, please open an issue on the repository.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Material Design for UI guidelines

---

**Built with ❤️ using Flutter and Supabase**
