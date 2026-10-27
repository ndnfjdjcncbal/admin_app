import 'package:adminapp/features/auth/data/model/usermodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel response parsing', () {
    test('parses a user from a wrapped login response', () {
      final user = UserModel.fromJson({
        'status': 'success',
        'data': {
          'user': {
            'user_id': 12,
            'user_name': 'Admin',
            'user_email': 'admin@example.com',
          },
        },
      });

      expect(user.id, '12');
      expect(user.name, 'Admin');
      expect(user.email, 'admin@example.com');
    });

    test('rejects a response that is missing required user fields', () {
      expect(
        () => UserModel.fromJson({'status': 'success', 'data': {}}),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('user_id, user_name, or user_email'),
          ),
        ),
      );
    });
  });
}
