import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/offline/domain/entities/offline_entities.dart';
import 'package:motodi_go_mobile/features/offline/domain/repositories/offline_repository.dart';

part 'offline_maps_state.dart';

@injectable
class OfflineMapsCubit extends Cubit<OfflineMapsState> {
  final OfflineRepository _repository;

  OfflineMapsCubit(this._repository) : super(const OfflineMapsState());

  Future<void> load() async {
    emit(state.copyWith(status: OfflineMapsStatus.loading, errorMessage: null));
    final usage = await _repository.storageUsage();
    final result = await _repository.getMapAreas();
    result.fold(
      (f) => emit(
        state.copyWith(
          status: OfflineMapsStatus.failure,
          errorMessage: f.message,
          usage: usage,
        ),
      ),
      (areas) => emit(
        state.copyWith(
          status: OfflineMapsStatus.success,
          areas: areas,
          usage: usage,
        ),
      ),
    );
  }

  Future<void> download(String id) async {
    final area = state.areas.where((a) => a.id == id).firstOrNull;
    if (area == null) return;
    emit(
      state.copyWith(
        downloadingId: id,
        downloadProgress: 0.0,
        errorMessage: null,
        successMessage: null,
      ),
    );
    final result = await _repository.downloadMapArea(
      area,
      onProgress: (p) {
        if (!isClosed) emit(state.copyWith(downloadProgress: p, downloadingId: id));
      },
    );
    await result.fold(
      (f) async {
        emit(
          state.copyWith(
            downloadingId: null,
            downloadProgress: null,
            errorMessage: f.message,
          ),
        );
      },
      (saved) async {
        final areas = state.areas.map((a) => a.id == saved.id ? saved : a).toList();
        final usage = await _repository.storageUsage();
        emit(
          state.copyWith(
            areas: areas,
            downloadingId: null,
            downloadProgress: null,
            usage: usage,
            successMessage: 'Pack téléchargé.',
          ),
        );
      },
    );
  }

  Future<void> delete(String id) async {
    await _repository.deleteMapArea(id);
    final areas = state.areas
        .map(
          (a) => a.id == id
              ? a.copyWith(downloaded: false, localPath: null, downloadProgress: null)
              : a,
        )
        .toList();
    final usage = await _repository.storageUsage();
    emit(state.copyWith(areas: areas, usage: usage));
  }
}
