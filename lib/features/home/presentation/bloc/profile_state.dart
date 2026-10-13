import '../../../auth/domain/entiti/entity_login.dart';

class ProfileState {
  const ProfileState({
    this.user,
    this.loading = false,
    this.error,
    this.notice,
  });

  final User? user;
  final bool loading;
  final String? error;
  final String? notice;
}
