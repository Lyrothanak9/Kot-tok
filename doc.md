lib/
├── app/
│   ├── app.dart                   # MaterialApp, Provider & Routes initialization
│   ├── routes.dart                # AppRoutes (/login, /signup, /main)
│   └── theme/
│       ├── app_colors.dart        # Color design tokens
│       ├── app_theme.dart         # Material 3 ThemeData
│       └── text_styles.dart       # Typography tokens (Roboto Flex)
│
├── models/
│   └── user_model.dart            # UserModel data model with JSON serialization
│
├── services/
│   ├── supabase_service.dart      # Supabase client singleton wrapper
│   └── auth_service.dart          # Remote Auth API calls (signIn, signUp, signOut)
│
├── providers/
│   ├── auth_provider.dart         # Auth State Management
│   └── navigation_provider.dart   # Bottom Navigation State Management
│
├── views/
│   ├── auth/
│   │   ├── sign_in_screen.dart    # Sign In screen
│   │   ├── sign_up_screen.dart    # Sign Up screen
│   │   └── widgets/               # Auth widgets (button, avatar, text fields, dividers)
│   └── main/
│       ├── main_navigation_screen.dart  # IndexedStack + BottomNavigationBar
│       ├── home_screen.dart             # Home tab screen
│       └── profile_screen.dart          # Profile tab screen
│
└── main.dart                       # Entry point & Supabase initialization