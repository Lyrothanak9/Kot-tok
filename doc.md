D:/Mobile-App-Project/
├── android/                         # Android native project configuration
├── assets/                          # Static assets (fonts, images, logo)
│   ├── fonts/                       # Roboto Flex font assets
│   └── images/                      # App icons and illustrations
├── ios/                             # iOS native project configuration
├── lib/                             # Core Flutter application source code
│   ├── app/                         # App-wide routing and design system
│   │   ├── app.dart                 # Root MaterialApp & MultiProvider setup
│   │   ├── routes.dart              # AppRoutes registry
│   │   └── theme/
│   │       ├── app_colors.dart      # Design token color palette
│   │       ├── app_theme.dart       # Material 3 ThemeData definition
│   │       └── text_styles.dart     # Typography styles
│   │
│   ├── core/                        # Core shared modules
│   │   ├── constants/
│   │   │   └── logo.dart            # Logo asset constants
│   │   └── services/
│   │       └── supabase_service.dart# Supabase client singleton
│   │
│   ├── features/                    # Feature modules
│   │   ├── Navigation/              # Main app shell & bottom bar
│   │   │   ├── provider/
│   │   │   │   └── bottom_app_bar_provider.dart
│   │   │   ├── screen/
│   │   │   │   └── main_navigation_screen.dart
│   │   │   └── widgets/
│   │   │       └── app_bar.dart
│   │   │
│   │   ├── auth/                    # Authentication feature
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── forget_password_screen.dart
│   │   │   │   ├── sign_in_screen.dart
│   │   │   │   └── sign_up_screen.dart
│   │   │   ├── services/
│   │   │   │   └── auth_service.dart
│   │   │   └── widgets/
│   │   │       ├── auth_bottom_prompt.dart
│   │   │       ├── button.dart
│   │   │       ├── image_profile_auth.dart
│   │   │       ├── line_divider.dart
│   │   │       ├── social_auth_button.dart
│   │   │       └── text_field.dart
│   │   │
│   │   ├── home/                    # Notes & dashboard feature
│   │   │   ├── models/
│   │   │   │   ├── category_model.dart
│   │   │   │   └── note_model.dart
│   │   │   ├── providers/
│   │   │   │   ├── category_provider.dart
│   │   │   │   ├── home_provider.dart
│   │   │   │   └── note_editor_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── note_editor_screen.dart
│   │   │   ├── services/
│   │   │   │   ├── category_service.dart
│   │   │   │   ├── home_service.dart
│   │   │   │   └── note_service.dart
│   │   │   └── widgets/
│   │   │       ├── dialog/
│   │   │       │   ├── create_label_dialog.dart
│   │   │       │   ├── delete_note_dialog.dart
│   │   │       │   ├── edit_label_dialog.dart
│   │   │       │   └── manage_labels_dialog.dart
│   │   │       ├── drawer_app.dart
│   │   │       ├── pinned_notes_list.dart
│   │   │       ├── recent_notes_list.dart
│   │   │       └── summary_stats_card.dart
│   │   │
│   │   └── splash/                  # Launch / Splash screen
│   │       ├── provider/
│   │       │   └── splash_provider.dart
│   │       └── screen/
│   │           └── splash_screen.dart
│   │
│   └── main.dart                    # App entrypoint & Supabase initialization
│
├── pubspec.yaml                     # Dependencies and asset registrations
└── README.md                        # Project documentation