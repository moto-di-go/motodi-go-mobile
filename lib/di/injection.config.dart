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
import 'package:motodi_go_mobile/features/nfc/data/datasources/nfc_local_datasource.dart'
    as _i256;
import 'package:motodi_go_mobile/features/nfc/data/datasources/nfc_remote_datasource.dart'
    as _i191;
import 'package:motodi_go_mobile/features/nfc/data/repositories/nfc_repository_impl.dart'
    as _i588;
import 'package:motodi_go_mobile/features/nfc/data/services/nfc_hardware_service.dart'
    as _i582;
import 'package:motodi_go_mobile/features/nfc/domain/repositories/nfc_repository.dart'
    as _i289;
import 'package:motodi_go_mobile/features/nfc/presentation/cubit/nfc_eligibility_cubit.dart'
    as _i513;
import 'package:motodi_go_mobile/features/nfc/presentation/cubit/nfc_emit_cubit.dart'
    as _i31;
import 'package:motodi_go_mobile/features/nfc/presentation/cubit/nfc_pay_cubit.dart'
    as _i62;
import 'package:motodi_go_mobile/features/nfc/presentation/cubit/nfc_pending_cubit.dart'
    as _i661;
import 'package:motodi_go_mobile/features/nfc/presentation/cubit/nfc_receive_cubit.dart'
    as _i719;
import 'package:motodi_go_mobile/features/nfc/presentation/cubit/nfc_sync_cubit.dart'
    as _i132;
import 'package:motodi_go_mobile/features/notifications/data/datasources/notification_remote_datasource.dart'
    as _i537;
import 'package:motodi_go_mobile/features/notifications/data/repositories/notification_repository_impl.dart'
    as _i838;
import 'package:motodi_go_mobile/features/notifications/domain/repositories/notification_repository.dart'
    as _i851;
import 'package:motodi_go_mobile/features/notifications/presentation/cubit/notifications_cubit.dart'
    as _i284;
import 'package:motodi_go_mobile/features/offline/data/datasources/offline_remote_datasource.dart'
    as _i166;
import 'package:motodi_go_mobile/features/offline/data/db/offline_local_store.dart'
    as _i50;
import 'package:motodi_go_mobile/features/offline/data/repositories/offline_repository_impl.dart'
    as _i783;
import 'package:motodi_go_mobile/features/offline/domain/repositories/offline_repository.dart'
    as _i149;
import 'package:motodi_go_mobile/features/offline/presentation/cubit/connectivity_cubit.dart'
    as _i106;
import 'package:motodi_go_mobile/features/offline/presentation/cubit/offline_maps_cubit.dart'
    as _i787;
import 'package:motodi_go_mobile/features/offline/presentation/cubit/offline_queue_cubit.dart'
    as _i694;
import 'package:motodi_go_mobile/features/offline/presentation/cubit/offline_settings_cubit.dart'
    as _i412;
import 'package:motodi_go_mobile/features/offline/presentation/cubit/offline_sync_cubit.dart'
    as _i594;
import 'package:motodi_go_mobile/features/post/data/datasources/post_remote_datasource.dart'
    as _i752;
import 'package:motodi_go_mobile/features/post/data/repositories/post_repository_impl.dart'
    as _i889;
import 'package:motodi_go_mobile/features/post/domain/repositories/post_repository.dart'
    as _i687;
import 'package:motodi_go_mobile/features/post/presentation/cubit/rating_cubit.dart'
    as _i884;
import 'package:motodi_go_mobile/features/post/presentation/cubit/receipts_cubit.dart'
    as _i351;
import 'package:motodi_go_mobile/features/post/presentation/cubit/support_cubit.dart'
    as _i714;
import 'package:motodi_go_mobile/features/post/presentation/cubit/trip_history_cubit.dart'
    as _i397;
import 'package:motodi_go_mobile/features/profiles/data/datasources/profile_remote_datasource.dart'
    as _i525;
import 'package:motodi_go_mobile/features/profiles/data/repositories/profile_repository_impl.dart'
    as _i278;
import 'package:motodi_go_mobile/features/profiles/domain/repositories/profile_repository.dart'
    as _i802;
import 'package:motodi_go_mobile/features/profiles/presentation/cubit/profile_cubit.dart'
    as _i747;
import 'package:motodi_go_mobile/features/trips/data/datasources/trip_remote_datasource.dart'
    as _i306;
import 'package:motodi_go_mobile/features/trips/data/datasources/trip_sse_client.dart'
    as _i469;
import 'package:motodi_go_mobile/features/trips/data/repositories/trip_repository_impl.dart'
    as _i257;
import 'package:motodi_go_mobile/features/trips/domain/repositories/trip_repository.dart'
    as _i705;
import 'package:motodi_go_mobile/features/trips/presentation/cubit/trip_track_cubit.dart'
    as _i72;
import 'package:motodi_go_mobile/features/wallet/data/datasources/wallet_remote_datasource.dart'
    as _i317;
import 'package:motodi_go_mobile/features/wallet/data/repositories/wallet_repository_impl.dart'
    as _i238;
import 'package:motodi_go_mobile/features/wallet/domain/repositories/wallet_repository.dart'
    as _i707;
import 'package:motodi_go_mobile/features/wallet/presentation/cubit/deposit_cubit.dart'
    as _i448;
import 'package:motodi_go_mobile/features/wallet/presentation/cubit/pay_booking_cubit.dart'
    as _i953;
import 'package:motodi_go_mobile/features/wallet/presentation/cubit/wallet_cubit.dart'
    as _i111;
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
    gh.lazySingleton<_i582.NfcHardwareService>(
      () => _i582.NfcHardwareService(),
    );
    gh.lazySingleton<_i317.WalletRemoteDataSource>(
      () => _i317.WalletRemoteDataSourceImpl(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i753.AuthRemoteDataSource>(
      () => _i753.AuthRemoteDataSourceImpl(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i162.IntercityRemoteDataSource>(
      () => _i162.IntercityRemoteDataSourceImpl(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i306.TripRemoteDataSource>(
      () => _i306.TripRemoteDataSourceImpl(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i191.NfcRemoteDataSource>(
      () => _i191.NfcRemoteDataSourceImpl(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i469.TripSseClient>(
      () => _i469.TripSseClient(gh<_i558.FlutterSecureStorage>()),
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
    gh.lazySingleton<_i752.PostRemoteDataSource>(
      () => _i752.PostRemoteDataSourceImpl(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i537.NotificationRemoteDataSource>(
      () => _i537.NotificationRemoteDataSourceImpl(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i435.NotificationService>(
      () => _i435.NotificationService(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i166.OfflineRemoteDataSource>(
      () => _i166.OfflineRemoteDataSourceImpl(gh<_i31.ChopperClient>()),
    );
    gh.lazySingleton<_i992.AuthLocalDataSource>(
      () => _i992.AuthLocalDataSourceImpl(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i256.NfcLocalDataSource>(
      () => _i256.NfcLocalDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i50.OfflineLocalStore>(
      () => _i50.OfflineLocalStore(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i247.NetworkInfo>(
      () => _i247.NetworkInfoImpl(gh<_i973.InternetConnectionChecker>()),
    );
    gh.lazySingleton<_i289.NfcRepository>(
      () => _i588.NfcRepositoryImpl(
        gh<_i191.NfcRemoteDataSource>(),
        gh<_i256.NfcLocalDataSource>(),
        gh<_i582.NfcHardwareService>(),
        gh<_i247.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i705.TripRepository>(
      () => _i257.TripRepositoryImpl(
        gh<_i306.TripRemoteDataSource>(),
        gh<_i247.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i851.NotificationRepository>(
      () => _i838.NotificationRepositoryImpl(
        gh<_i537.NotificationRemoteDataSource>(),
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
    gh.factory<_i72.TripTrackCubit>(
      () => _i72.TripTrackCubit(
        gh<_i705.TripRepository>(),
        gh<_i469.TripSseClient>(),
      ),
    );
    gh.factory<_i31.NfcEmitCubit>(
      () => _i31.NfcEmitCubit(
        gh<_i289.NfcRepository>(),
        gh<_i582.NfcHardwareService>(),
      ),
    );
    gh.factory<_i719.NfcReceiveCubit>(
      () => _i719.NfcReceiveCubit(
        gh<_i289.NfcRepository>(),
        gh<_i582.NfcHardwareService>(),
      ),
    );
    gh.factory<_i513.NfcEligibilityCubit>(
      () => _i513.NfcEligibilityCubit(gh<_i289.NfcRepository>()),
    );
    gh.factory<_i62.NfcPayCubit>(
      () => _i62.NfcPayCubit(gh<_i289.NfcRepository>()),
    );
    gh.factory<_i661.NfcPendingCubit>(
      () => _i661.NfcPendingCubit(gh<_i289.NfcRepository>()),
    );
    gh.factory<_i132.NfcSyncCubit>(
      () => _i132.NfcSyncCubit(gh<_i289.NfcRepository>()),
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
    gh.factory<_i284.NotificationsCubit>(
      () => _i284.NotificationsCubit(gh<_i851.NotificationRepository>()),
    );
    gh.lazySingleton<_i707.WalletRepository>(
      () => _i238.WalletRepositoryImpl(
        gh<_i317.WalletRemoteDataSource>(),
        gh<_i247.NetworkInfo>(),
      ),
    );
    gh.factory<_i657.KycCubit>(() => _i657.KycCubit(gh<_i9.KycRepository>()));
    gh.lazySingleton<_i149.OfflineRepository>(
      () => _i783.OfflineRepositoryImpl(
        gh<_i166.OfflineRemoteDataSource>(),
        gh<_i50.OfflineLocalStore>(),
        gh<_i289.NfcRepository>(),
        gh<_i247.NetworkInfo>(),
      ),
    );
    gh.factory<_i448.DepositCubit>(
      () => _i448.DepositCubit(gh<_i707.WalletRepository>()),
    );
    gh.factory<_i953.PayBookingCubit>(
      () => _i953.PayBookingCubit(gh<_i707.WalletRepository>()),
    );
    gh.factory<_i111.WalletCubit>(
      () => _i111.WalletCubit(gh<_i707.WalletRepository>()),
    );
    gh.factory<_i787.OfflineMapsCubit>(
      () => _i787.OfflineMapsCubit(gh<_i149.OfflineRepository>()),
    );
    gh.factory<_i694.OfflineQueueCubit>(
      () => _i694.OfflineQueueCubit(gh<_i149.OfflineRepository>()),
    );
    gh.factory<_i412.OfflineSettingsCubit>(
      () => _i412.OfflineSettingsCubit(gh<_i149.OfflineRepository>()),
    );
    gh.factory<_i594.OfflineSyncCubit>(
      () => _i594.OfflineSyncCubit(gh<_i149.OfflineRepository>()),
    );
    gh.lazySingleton<_i802.ProfileRepository>(
      () => _i278.ProfileRepositoryImpl(
        gh<_i525.ProfileRemoteDataSource>(),
        gh<_i247.NetworkInfo>(),
        gh<_i149.OfflineRepository>(),
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
    gh.lazySingleton<_i687.PostRepository>(
      () => _i889.PostRepositoryImpl(
        gh<_i752.PostRemoteDataSource>(),
        gh<_i247.NetworkInfo>(),
        gh<_i149.OfflineRepository>(),
      ),
    );
    gh.lazySingleton<_i106.ConnectivityCubit>(
      () => _i106.ConnectivityCubit(
        gh<_i149.OfflineRepository>(),
        gh<_i289.NfcRepository>(),
      ),
    );
    gh.factory<_i747.ProfileCubit>(
      () => _i747.ProfileCubit(gh<_i802.ProfileRepository>()),
    );
    gh.factory<_i351.ReceiptsCubit>(
      () => _i351.ReceiptsCubit(gh<_i687.PostRepository>()),
    );
    gh.factory<_i714.SupportCubit>(
      () => _i714.SupportCubit(gh<_i687.PostRepository>()),
    );
    gh.factory<_i397.TripHistoryCubit>(
      () => _i397.TripHistoryCubit(gh<_i687.PostRepository>()),
    );
    gh.lazySingleton<_i1053.IntercityRepository>(
      () => _i115.IntercityRepositoryImpl(
        gh<_i162.IntercityRemoteDataSource>(),
        gh<_i247.NetworkInfo>(),
        gh<_i149.OfflineRepository>(),
      ),
    );
    gh.factory<_i884.RatingCubit>(
      () => _i884.RatingCubit(
        gh<_i687.PostRepository>(),
        gh<_i705.TripRepository>(),
      ),
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
    gh.factory<_i57.ExampleBloc>(
      () => _i57.ExampleBloc(gh<_i569.GetExamplesUseCase>()),
    );
    gh.factory<_i741.IntercityBookingCubit>(
      () => _i741.IntercityBookingCubit(
        gh<_i1053.IntercityRepository>(),
        gh<_i31.ChopperClient>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i568.RegisterModule {}
