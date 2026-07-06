import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_template_app/di/injection.dart';
import 'package:flutter_template_app/core/widgets/app_loading.dart';
import 'package:flutter_template_app/core/widgets/app_error_view.dart';
import 'package:flutter_template_app/features/example/presentation/bloc/example_bloc.dart';

// Rôle : Page principale de la feature example. Illustre le pattern BLoC complet.
class ExampleListPage extends StatelessWidget {
  final ExampleBloc? bloc;

  const ExampleListPage({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    final effectiveBloc = bloc ?? getIt<ExampleBloc>();

    // Si on utilise le bloc du getIt, on lance l'initialisation
    if (bloc == null) {
      effectiveBloc.add(const GetExamplesRequested());
    }

    return BlocProvider.value(value: effectiveBloc, child: const _ExampleListView());
  }
}

class _ExampleListView extends StatelessWidget {
  const _ExampleListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemples'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ExampleBloc>().add(const ExampleRefreshRequested()),
          ),
        ],
      ),
      body: BlocBuilder<ExampleBloc, ExampleState>(
        builder: (context, state) {
          if (state.isLoading || state.status == ExampleStatus.initial) {
            return const AppLoading();
          }
          if (state.isFailure) {
            return AppErrorView(
              message: state.errorMessage ?? 'Une erreur est survenue',
              onRetry: () => context.read<ExampleBloc>().add(const GetExamplesRequested()),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/examples/${item.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
