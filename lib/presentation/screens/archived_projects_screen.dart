import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/study_project.dart';
import '../providers/providers.dart';

class ArchivedProjectsScreen extends ConsumerWidget {
  const ArchivedProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final archivedAsync = ref.watch(archivedProjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Archived')),
      body: archivedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (projects) {
          if (projects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No archived study plans.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: projects.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _ArchivedTile(project: projects[index]),
          );
        },
      ),
    );
  }
}

class _ArchivedTile extends ConsumerWidget {
  final StudyProject project;
  const _ArchivedTile({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.name, style: theme.textTheme.titleMedium),
                  if (project.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      project.description!,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(studyProjectsProvider.notifier)
                    .setArchived(project.id, false);
              },
              child: const Text('Unarchive'),
            ),
          ],
        ),
      ),
    );
  }
}
