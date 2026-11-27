import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _fullName = 'User';
  String _email = 'No email';
  String? _avatarUrl;
  bool _isSigningOut = false;
  bool _isDisposed = false;

  String get fullName => _fullName;
  String get email => _email;
  String? get avatarUrl => _avatarUrl;
  bool get isSigningOut => _isSigningOut;

  ProfileProvider() {
    _init();
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _init() {
    _loadAuthUser();
    _fetchProfileFromDatabase();
  }

  /// Reads immediately from the active Supabase Auth session so there is no blank flicker.
  void _loadAuthUser() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final metadata = user.userMetadata ?? {};

    _email = user.email ?? 'No email';
    _fullName = (metadata['full_name'] ??
            metadata['name'] ??
            _email.split('@').first)
        .toString()
        .trim();
    if (_fullName.isEmpty) _fullName = 'User';

    _avatarUrl = (metadata['avatar_url'] ?? metadata['picture'])?.toString();
    _notify();
  }

  /// Syncs the latest profile name/avatar from your `profiles` table if available.
  Future<void> _fetchProfileFromDatabase() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await _supabase
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null || _isDisposed) return;

      final dbName = profile['full_name']?.toString().trim();
      if (dbName != null && dbName.isNotEmpty) {
        _fullName = dbName;
      }
      final dbAvatar = profile['avatar_url']?.toString().trim();
      if (dbAvatar != null && dbAvatar.isNotEmpty) {
        _avatarUrl = dbAvatar;
      }
      _notify();
    } catch (e) {
      // Falls back gracefully to auth metadata if `avatar_url` column doesn't exist yet
      debugPrint('ProfileProvider fetch notice: $e');
    }
  }

  Future<void> signOut() async {
    if (_isSigningOut) return;

    _isSigningOut = true;
    _notify();

    try {
      await _supabase.auth.signOut();
    } finally {
      _isSigningOut = false;
      _notify();
    }
  }
}
