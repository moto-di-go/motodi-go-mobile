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
    gh.lazySingleton<_i247.NetworkInfo>(
      () => _i247.NetworkInfoImpl(gh<_i973.InternetConnectionChecker>()),
    );
    gh.lazySingleton<_i697.ExampleRepository>(
      () => _i387.ExampleRepositoryImpl(
        gh<_i1016.ExampleRemoteDataSource>(),
        gh<_i247.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i569.GetExamplesUseCase>(
      () => _i569.GetExamplesUseCase(gh<_i697.ExampleRepository>()),
    );
    gh.factory<_i57.ExampleBloc>(
      () => _i57.ExampleBloc(gh<_i569.GetExamplesUseCase>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i568.RegisterModule {}
