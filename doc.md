lib/
├── app/
│   ├── app.dart                   # MultiProvider root & MaterialApp
│   ├── routes.dart                # Navigator 2.0 / GoRouter setup
│   └── theme/
│       ├── app_colors.dart
│       ├── app_theme.dart
│       └── text_styles.dart
│
├── core/
│   ├── constants/
│   │   ├── storage_keys.dart
│   │   └── supabase_constants.dart # URL, Anon key, table/bucket names
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── services/
│   │   ├── local_storage.dart     # Offline storage wrapper (e.g. Hive/SQLite)
│   │   └── supabase_service.dart   # Supabase client wrapper & shortcuts
│   └── utils/
│       ├── date_formatter.dart
│       └── debouncer.dart         # Auto-save debouncer for editor
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/auth_remote_source.dart
│   │   │   ├── models/user_model.dart
│   │   │   └── repositories/auth_repository.dart
│   │   ├── view/
│   │   │   ├── providers/auth_provider.dart  # <-- ChangeNotifier for login/session state
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   └── widgets/auth_text_field.dart
│   │
│   ├── notes/
│   │   ├── data/
│   │   │   ├── datasource/
│   │   │   │   ├── note_local_source.dart    # SQLite/Hive cache
│   │   │   │   └── note_supabase_source.dart # Supabase table queries & stream
│   │   │   ├── models/note_model.dart
│   │   │   └── repositories/note_repository.dart
│   │   ├── domain/
│   │   │   └── entities/note.dart
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   ├── note_list_provider.dart   # <-- ChangeNotifier (fetches, filters, pins)
│   │   │   │   └── note_editor_provider.dart # <-- ChangeNotifier (debounced auto-save)
│   │   │   ├── screens/
│   │   │   │   ├── note_list_screen.dart
│   │   │   │   ├── note_editor_screen.dart
│   │   │   │   └── search_notes_screen.dart
│   │   │   └── widgets/
│   │   │       ├── note_card.dart
│   │   │       ├── note_toolbar.dart
│   │   │       └── color_picker_bottom_sheet.dart
│   │
│   └── labels/
│       ├── data/
│       │   ├── models/label_model.dart
│       │   └── repositories/label_repository.dart
│       ├── presentation/
│       │   ├── providers/label_provider.dart # <-- ChangeNotifier for tags/categories
│       │   ├── screens/manage_labels_screen.dart
│       │   └── widgets/label_chip.dart
│
├── shared/
│   ├── extensions/
│   │   ├── context_extensions.dart           # e.g., context.read<T>(), context.watch<T>()
│   │   └── string_extensions.dart
│   └── widgets/
│       ├── custom_app_bar.dart
│       ├── empty_state_view.dart
│       └── loading_indicator.dart
│
└── main.dart