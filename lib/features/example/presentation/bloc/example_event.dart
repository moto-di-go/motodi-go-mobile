part of 'example_bloc.dart';

abstract class ExampleEvent extends Equatable {
  const ExampleEvent();

  @override
  List<Object?> get props => [];
}

class GetExamplesRequested extends ExampleEvent {
  const GetExamplesRequested();
}

class ExampleRefreshRequested extends ExampleEvent {
  const ExampleRefreshRequested();
}
