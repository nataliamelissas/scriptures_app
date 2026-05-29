import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../providers/providers.dart';

/// Lists the standard works NOT already added to [project] so the user
/// can add one. Pops on selection. The actual add happens through
/// [StudyProjectsNotifier.addVolume] and returns the updated project
/// via [Navigator.pop] for the caller to refresh state.
class AddVolumeScreen extends ConsumerWidget {
  final StudyProject project;
  const AddVolumeScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final available = StandardWork.values
        .where((v) => !project.volumes.contains(v))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Standard Work'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: available.isEmpty
            ? _AllAddedState(theme: theme)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pick a volume to add to "${project.name}".',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: available.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final volume = available[i];
                        return _AddVolumeCard(
                          volume: volume,
                          onTap: () => _onTap(context, ref, volume),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref,
    StandardWork volume,
  ) async {
    final updated = await ref
        .read(studyProjectsProvider.notifier)
        .addVolume(project, volume);
    if (!context.mounted) return;
    Navigator.pop(context, updated);
  }
}

class _AllAddedState extends StatelessWidget {
  final ThemeData theme;
  const _AllAddedState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 56,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'All standard works added',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'This study plan already covers every volume.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AddVolumeCard extends StatelessWidget {
  final StandardWork volume;
  final VoidCallback onTap;
  const _AddVolumeCard({required this.volume, required this.onTap});

  IconData get _icon => switch (volume) {
        StandardWork.oldTestament => Icons.history_edu_rounded,
        StandardWork.newTestament => Icons.auto_stories_rounded,
        StandardWork.bookOfMormon => Icons.menu_book_rounded,
        StandardWork.doctrineAndCovenants => Icons.gavel_rounded,
        StandardWork.pearlOfGreatPrice => Icons.diamond_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(_icon, size: 22, color: theme.colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  volume.displayName,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.add, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
