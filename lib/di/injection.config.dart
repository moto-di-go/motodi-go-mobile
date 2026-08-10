// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:chopper/chopper.dart' as _i31;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i973;
import 'package:logger/logger.dart' as _i974;
import 'package:motodi_go_mobile/core/network/network_info.dart' as _i247;
import 'package:motodi_go_mobile/core/services/notification_service.dart'
    as _i435;
import 'package:motodi_go_mobile/di/register_module.dart' as _i568;
import 'package:motodi_go_mobile/features/auth/data/datasources/auth_local_datasource.dart'
    as _i992;
import 'package:motodi_go_mobile/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i753;
import 'package:motodi_go_mobile/features/auth/data/repositories/auth_repository_impl.dart'
    as _i890;
import 'package:motodi_go_mobile/features/auth/domain/repositories/auth_repository.dart'
    as _i1053;
import 'package:motodi_go_mobile/features/auth/presentation/cubit/auth_form_cubit.dart'
    as _i459;
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart'
    as _i493;
import 'package:motodi_go_mobile/features/example/data/datasources/example_remote_datasource.dart'
    as _i1016;
import 'package:motodi_go_mobile/features/example/data/repositories/example_repository_impl.dart'
    as _i387;
import 'package:motodi_go_mobile/features/example/domain/repositories/example_repository.dart'
    as _i697;
import 'package:motodi_go_mobile/features/example/domain/usecases/get_examples_usecase.dart'
    as _i569;
import 'package:motodi_go_mobile/features/example/presentation/bloc/example_bloc.dart'
    as _i57;
import 'package:motodi_go_mobile/features/intercity/data/datasources/intercity_remote_datasource.dart'
    as _i162;
import 'package:motodi_go_mobile/features/intercity/data/repositories/intercity_repository_impl.dart'
    as _i115;
import 'package:motodi_go_mobile/features/intercity/domain/repositories/intercity_repository.dart'
    as _i1053;
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_booking_cubit.dart'
    as _i741;
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_publish_cubit.dart'
    as _i1051;
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_search_cubit.dart'
    as _i183;
import 'package:motodi_go_mobile/features/kyc/data/datasources/kyc_remote_datasource.dart'
    as _i29;
import 'package:motodi_go_mobile/features/kyc/data/repositories/kyc_repository_impl.dart'
    as _i356;
import 'package:motodi_go_mobile/features/kyc/domain/repositories/kyc_repository.dart'
    as _i9;
import 'package:motodi_go_mobile/features/kyc/presentation/cubit/kyc_cubit.dart'
    as _i657;
import 'package:motodi_go_mobile/features/profiles/data/datasources/profile_remote_datasource.dart'
    as _i525;
import 'package:motodi_go_mobile/features/profiles/data/repositories/profile_repository_impl.dart'
    as _i278;
import 'package:motodi_go_mobile/features/profiles/domain/repositories/profile_repository.dart'
    as _i802;
import 'package:motodi_go_mobile/features/profiles/presentation/cubit/profile_cubit.dart'
    as _i747;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i435.NotificationService>(
      () => _i435.NotificationService(),
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i31.ChopperClient>(() => registerModule.chopperClient);
    gh.lazySingleton<_i974.Logger>(() => registerModule.logger);
    gh.lazySingleton<_i973.InternetConnectionChecker>(
      () => registerModule.connectionChecker,
    );
    gh.lazySingleton<_i1016.ExampleRemoteDataSource>(
      () => _i1016.ExampleRemoteDataSource(),
    );
    gh.lazySingleton<_i753.AuthRemoteDataSource>(
      () => _i753.AuthRemoteDataSourceImpl(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i162.IntercityRemoteDataSource>(
      () => _i162.IntercityRemoteDataSourceImpl(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i525.ProfileRemoteDataSource>(
      () => _i525.ProfileRemoteDataSourceImpl(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i29.KycRemoteDataSource>(
      () => _i29.KycRemoteDataSourceImpl(
        gh<_i31.ChopperClient>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i992.AuthLocalDataSource>(
      () => _i992.AuthLocalDataSourceImpl(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i247.NetworkInfo>(
      () => _i247.NetworkInfoImpl(gh<_i973.InternetConnectionChecker>()),
    );
    gh.lazySingleton<_i1053.IntercityRepository>(
      () => _i115.IntercityRepositoryImpl(
        gh<_i162.IntercityRemoteDataSource>(),
        gh<_i247.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i9.KycRepository>(
      () => _i356.KycRepositoryImpl(
        gh<_i29.KycRemoteDataSource>(),
        gh<_i247.NetworkInfo>(),
        gh<_i992.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i802.ProfileRepository>(
      () => _i278.ProfileRepositoryImpl(
        gh<_i525.ProfileRemoteDataSource>(),
        gh<_i247.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i1053.AuthRepository>(
      () => _i890.AuthRepositoryImpl(
        gh<_i753.AuthRemoteDataSource>(),
        gh<_i992.AuthLocalDataSource>(),
        gh<_i247.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i697.ExampleRepository>(
      () => _i387.ExampleRepositoryImpl(
        gh<_i1016.ExampleRemoteDataSource>(),
        gh<_i247.NetworkInfo>(),
      ),
    );
    gh.factory<_i657.KycCubit>(() => _i657.KycCubit(gh<_i9.KycRepository>()));
    gh.factory<_i741.IntercityBookingCubit>(
      () => _i741.IntercityBookingCubit(gh<_i1053.IntercityRepository>()),
    );
    gh.factory<_i183.IntercitySearchCubit>(
      () => _i183.IntercitySearchCubit(gh<_i1053.IntercityRepository>()),
    );
    gh.factory<_i1051.IntercityPublishCubit>(
      () => _i1051.IntercityPublishCubit(
        gh<_i1053.IntercityRepository>(),
        gh<_i802.ProfileRepository>(),
      ),
    );
    gh.factory<_i459.AuthFormCubit>(
      () => _i459.AuthFormCubit(gh<_i1053.AuthRepository>()),
    );
    gh.lazySingleton<_i493.SessionCubit>(
      () => _i493.SessionCubit(gh<_i1053.AuthRepository>()),
    );
    gh.lazySingleton<_i569.GetExamplesUseCase>(
      () => _i569.GetExamplesUseCase(gh<_i697.ExampleRepository>()),
    );
    gh.factory<_i747.ProfileCubit>(
      () => _i747.ProfileCubit(gh<_i802.ProfileRepository>()),
    );
    gh.factory<_i57.ExampleBloc>(
      () => _i57.ExampleBloc(gh<_i569.GetExamplesUseCase>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i568.RegisterModule {}
