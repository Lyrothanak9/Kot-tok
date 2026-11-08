import 'package:flutter_test/flutter_test.dart';
import 'package:kot_tok/features/auth/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('should correctly deserialize UserModel from JSON', () {
      final json = {
        'id': 'user_123',
        'email': 'test@example.com',
        'name': 'John Doe',
        'avatar_url': 'https://example.com/avatar.png',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user_123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'John Doe');
      expect(user.avatarUrl, 'https://example.com/avatar.png');
    });

    test('should handle optional null fields in JSON', () {
      final json = {
        'id': 'user_456',
        'email': 'jane@example.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user_456');
      expect(user.email, 'jane@example.com');
      expect(user.name, isNull);
      expect(user.avatarUrl, isNull);
    });

    test('should correctly serialize UserModel to JSON', () {
      const user = UserModel(
        id: 'user_789',
        email: 'admin@example.com',
        name: 'Admin',
        avatarUrl: 'https://example.com/admin.png',
      );

      final json = user.toJson();

      expect(json, {
        'id': 'user_789',
        'email': 'admin@example.com',
        'name': 'Admin',
        'avatar_url': 'https://example.com/admin.png',
      });
    });
  });
}
