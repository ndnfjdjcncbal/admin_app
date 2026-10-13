import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileState());

  final ProfileRepository _repository;

  Future<void> loadProfile() async {
    emit(ProfileState(user: state.user, loading: true));
    try {
      final user = await _repository.getProfile();
      emit(ProfileState(user: user));
    } catch (error) {
      emit(ProfileState(user: state.user, error: error.toString()));
    }
  }

  void requestProfileEdit() {
    emit(
      ProfileState(
        user: state.user,
        error: state.error,
        notice: 'Profile editing will be available after the profile update API is connected.',
      ),
    );
  }
}
