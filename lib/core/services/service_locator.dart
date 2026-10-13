import 'package:adminapp/features/auth/data/Repositories/auth_repository_impl.dart';
import 'package:adminapp/features/auth/data/local_data_source/auth_local_data_source.dart';
import 'package:adminapp/features/auth/data/remote_data_source/auth_remot_data_source.dart';
import 'package:adminapp/features/auth/domain/repo/auth_repo.dart';
import 'package:adminapp/features/auth/domain/use_cases/login_usecase.dart';
import 'package:adminapp/features/auth/domain/use_cases/register_usecase.dart';
import 'package:adminapp/features/auth/domain/use_cases/request_password_reset_code_usecase.dart';
import 'package:adminapp/features/auth/domain/use_cases/resend_password_reset_code_usecase.dart';
import 'package:adminapp/features/auth/domain/use_cases/reset_password_usecase.dart';
import 'package:adminapp/features/auth/domain/use_cases/verify_password_reset_code_usecase.dart';
import 'package:adminapp/features/auth/domain/use_cases/verify_signup_code_usecase.dart';
import 'package:adminapp/features/auth/presentaion/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:adminapp/features/auth/presentaion/bloc/login/login_bloc.dart';
import 'package:adminapp/features/auth/presentaion/bloc/signup/signup_bloc.dart';
import 'package:adminapp/features/home/data/remote_data_source/catalog_remote_data_source.dart';
import 'package:adminapp/features/home/data/repositories/catalog_repository_impl.dart';
import 'package:adminapp/features/home/data/repositories/profile_repository_impl.dart';
import 'package:adminapp/features/home/presentation/bloc/catalog_cubit.dart';
import 'package:adminapp/features/home/presentation/bloc/home_cubit.dart';
import 'package:adminapp/features/home/presentation/bloc/profile_cubit.dart';
import 'package:adminapp/features/home/domain/repositories/catalog_repository.dart';
import 'package:adminapp/features/home/domain/repositories/profile_repository.dart';
import 'package:adminapp/features/orders/data/remote_data_source/orders_remote_data_source.dart';
import 'package:adminapp/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:adminapp/features/orders/domain/repositories/orders_repository.dart';
import 'package:adminapp/features/orders/domain/use_cases/approve_order_use_case.dart';
import 'package:adminapp/features/orders/domain/use_cases/get_new_orders_use_case.dart';
import 'package:adminapp/features/orders/domain/use_cases/reject_order_use_case.dart';
import 'package:adminapp/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:adminapp/core/services/Mysevice.dart';
import 'package:adminapp/core/services/notifications/notification_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_consumer.dart';

final sl = GetIt.instance;

void initDependencies() {
  sl.registerSingletonAsync<SharedPreferences>(
    () async => await SharedPreferences.getInstance(),
  );

  sl.registerLazySingleton<Myservice>(
    () => Myservice(sharedPreferences: sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<Dio>(() => Dio());

  sl.registerLazySingleton<DioConsumer>(() => DioConsumer(sl<Dio>()));

  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(sl<Myservice>(), sl<DioConsumer>()),
  );

  sl.registerLazySingleton<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSource(sl<DioConsumer>()),
  );

  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSource(sl<DioConsumer>()),
  );

  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(sl<OrdersRemoteDataSource>()),
  );

  sl.registerFactory<GetNewOrdersUseCase>(
    () => GetNewOrdersUseCase(sl<OrdersRepository>()),
  );
  sl.registerFactory<ApproveOrderUseCase>(
    () => ApproveOrderUseCase(sl<OrdersRepository>()),
  );
  sl.registerFactory<RejectOrderUseCase>(
    () => RejectOrderUseCase(sl<OrdersRepository>()),
  );
  sl.registerFactory<OrdersCubit>(
    () => OrdersCubit(
      getNewOrders: sl<GetNewOrdersUseCase>(),
      approveOrder: sl<ApproveOrderUseCase>(),
      rejectOrder: sl<RejectOrderUseCase>(),
    ),
  );

  sl.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(sl<CatalogRemoteDataSource>()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<AuthLocalDataSource>()),
  );

  sl.registerFactory<CatalogCubit>(() => CatalogCubit(sl<CatalogRepository>()));

  sl.registerFactory<HomeCubit>(() => HomeCubit());

  sl.registerFactory<ProfileCubit>(() => ProfileCubit(sl<ProfileRepository>()));

  sl.registerLazySingleton<AuthRemotDataSource>(
    () => AuthRemotDataSource(sl<DioConsumer>()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemotDataSource>(),
      sl<AuthLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<RequestPasswordResetCodeUseCase>(
    () => RequestPasswordResetCodeUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifyPasswordResetCodeUseCase>(
    () => VerifyPasswordResetCodeUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ResendPasswordResetCodeUseCase>(
    () => ResendPasswordResetCodeUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifySignupCodeUseCase>(
    () => VerifySignupCodeUseCase(sl<AuthRepository>()),
  );

  sl.registerFactory<SignupBloc>(
    () => SignupBloc(
      usecase: sl<RegisterUseCase>(),
      verifySignupCodeUseCase: sl<VerifySignupCodeUseCase>(),
      resendCodeUseCase: sl<ResendPasswordResetCodeUseCase>(),
    ),
  );

  sl.registerFactory<LoginBloc>(() => LoginBloc(usecase: sl<LoginUseCase>()));
  sl.registerFactory<ForgotPasswordBloc>(
    () => ForgotPasswordBloc(
      requestCodeUseCase: sl<RequestPasswordResetCodeUseCase>(),
      verifyCodeUseCase: sl<VerifyPasswordResetCodeUseCase>(),
      resendCodeUseCase: sl<ResendPasswordResetCodeUseCase>(),
      resetPasswordUseCase: sl<ResetPasswordUseCase>(),
    ),
  );
}
