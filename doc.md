# Project Structure Summary

```
lib/
├── app/
│   ├── app.dart                   # MaterialApp, Provider setup & initial route
│   ├── routes.dart                # AppRoutes mapping (/login, /signup, /main)
│   └── theme/
│       ├── app_colors.dart        # Color design tokens & palette
│       ├── app_theme.dart         # Material Design 3 ThemeData configuration
│       └── text_styles.dart       # Typography styles & Roboto Flex font setup
│
├── core/
│   ├── constants/                 # App constants & keys
│   └── services/
│       └── supabase_service.dart  # Supabase client singleton wrapper
│
├── features/
│   ├── auth/
│   │   ├── models/
│   │   │   └── user_model.dart    # UserModel data class
│   │   ├── providers/
│   │   │   └── auth_provider.dart # Auth State Management (login, signUp)
│   │   ├── services/
│   │   │   └── auth_service.dart  # Remote Auth API integration
│   │   ├── screens/
│   │   │   ├── sign_in_screen.dart # Sign In screen UI & form logic
│   │   │   └── sign_up_screen.dart # Sign Up screen UI & form logic
│   │   └── widgets/
│   │       ├── auth_buttom_prompt.dart  # Reusable bottom navigation prompt link
│   │       ├── button.dart              # Gradient submit button with spinner
│   │       ├── image_profile_auth.dart  # Responsive profile avatar & header title
│   │       ├── line_divider.dart        # "Or continue with" section divider
│   │       ├── social_auth_button.dart  # Responsive full-width social auth button
│   │       └── text_field.dart          # Reusable text input field with validation
│   │
│   └── home/
│       ├── models/                # Home data models
│       ├── providers/
│       │   └── navigation_provider.dart # Bottom navigation index manager
│       ├── services/              # Home API services
│       ├── screens/
│       │   ├── home_screen.dart             # Home tab screen
│       │   ├── main_navigation_screen.dart  # IndexedStack + BottomNavigationBar
│       │   └── profile_screen.dart          # Profile tab screen
│       └── widgets/               # Home feature widgets
│
└── main.dart                       # App entry point & Supabase initialization
```
