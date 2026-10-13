import '../../../auth/data/local_data_source/auth_local_data_source.dart';
import '../../../auth/domain/entiti/entity_login.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._localDataSource);

  final AuthLocalDataSource _localDataSource;

  @override
  Future<User?> getProfile() => _localDataSource.getUser();
}
