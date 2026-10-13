import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void selectTab(int index) {
    if (index == state.selectedTab) return;
    emit(HomeState(selectedTab: index));
  }

  void openNotifications() {
    emit(
      HomeState(
        selectedTab: state.selectedTab,
        notice: 'Notifications API is not connected yet.',
      ),
    );
  }
}
