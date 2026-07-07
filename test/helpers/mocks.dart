import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/example/data/datasources/example_remote_datasource.dart';
import 'package:motodi_go_mobile/features/example/domain/repositories/example_repository.dart';
import 'package:motodi_go_mobile/features/example/domain/usecases/get_examples_usecase.dart';
import 'package:motodi_go_mobile/features/example/presentation/bloc/example_bloc.dart';

// Mocks centralisés — importer dans les tests avec :
// import '../../helpers/mocks.dart';
class MockExampleRepository extends Mock implements ExampleRepository {}

class MockExampleRemoteDataSource extends Mock implements ExampleRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockGetExamplesUseCase extends Mock implements GetExamplesUseCase {}

class MockExampleBloc extends MockBloc<ExampleEvent, ExampleState> implements ExampleBloc {}
