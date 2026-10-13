import '../../../auth/domain/entiti/entity_login.dart';

abstract class ProfileRepository {
  Future<User?> getProfile();
}
