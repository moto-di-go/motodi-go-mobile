part of 'example_bloc.dart';

enum ExampleStatus { initial, loading, success, failure }

class ExampleState extends Equatable {
  final ExampleStatus status;
  final List<ExampleEntity> items;
  final String? errorMessage;

  const ExampleState({
    this.status = ExampleStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  ExampleState copyWith({ExampleStatus? status, List<ExampleEntity>? items, String? errorMessage}) {
    return ExampleState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == ExampleStatus.loading;
  bool get isSuccess => status == ExampleStatus.success;
  bool get isFailure => status == ExampleStatus.failure;

  @override
  List<Object?> get props => [status, items, errorMessage];
}
