import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template_app/di/injection.dart';
import 'package:flutter_template_app/features/example/presentation/bloc/example_bloc.dart';

// Rôle : Page de détail de la feature example.
class ExampleDetailPage extends StatelessWidget {
  final String itemId;
  final ExampleBloc? bloc;

  const ExampleDetailPage({super.key, required this.itemId, this.bloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc ?? getIt<ExampleBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Détail')),
        body: BlocBuilder<ExampleBloc, ExampleState>(
          builder: (context, state) {
            final item = state.items.where((i) => i.id == itemId).firstOrNull;
            if (item == null) {
              return const Center(child: Text('Element non trouvé'));
            }
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Créé le ${item.createdAt.toLocal()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(item.description, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
