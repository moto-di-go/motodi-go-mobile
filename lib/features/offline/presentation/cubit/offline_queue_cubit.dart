import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/offline/domain/entities/offline_entities.dart';
import 'package:motodi_go_mobile/features/offline/domain/repositories/offline_repository.dart';

part 'offline_queue_state.dart';

@injectable
class OfflineQueueCubit extends Cubit<OfflineQueueState> {
  final OfflineRepository _repository;

  OfflineQueueCubit(this._repository) : super(const OfflineQueueState());

  Future<void> load() async {
    emit(state.copyWith(status: OfflineQueueStatus.loading));
    final local = await _repository.listLocalOperations();
    emit(state.copyWith(status: OfflineQueueStatus.success, operations: local));
  }
}
