import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_template_app/features/example/domain/entities/example_entity.dart';
import 'package:flutter_template_app/features/example/domain/usecases/get_examples_usecase.dart';

part 'example_event.dart';
part 'example_state.dart';

// Rôle : BLoC de la feature example. Gère les états loading/success/failure.
// Dépendances : GetExamplesUseCase
// Pattern : Event -> BLoC -> State -> UI
@injectable
class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  final GetExamplesUseCase _getExamples;

  ExampleBloc(this._getExamples) : super(const ExampleState()) {
    on<GetExamplesRequested>(_onGetExamples);
    on<ExampleRefreshRequested>(_onRefresh);
  }

  Future<void> _onGetExamples(GetExamplesRequested event, Emitter<ExampleState> emit) async {
    emit(state.copyWith(status: ExampleStatus.loading));
    final result = await _getExamples();
    result.fold(
      (failure) =>
          emit(state.copyWith(status: ExampleStatus.failure, errorMessage: failure.message)),
      (items) => emit(state.copyWith(status: ExampleStatus.success, items: items)),
    );
  }

  Future<void> _onRefresh(ExampleRefreshRequested event, Emitter<ExampleState> emit) async {
    await _onGetExamples(const GetExamplesRequested(), emit);
  }
}
