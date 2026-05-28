import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/entities/study_project.dart';
import '../providers/providers.dart';
import 'books_screen.dart';
import 'study_plan_created_screen.dart';

/// Displays the 5 standard works as a compact list.
///
/// [isInitialSetup] = true when this is the project-creation flow: picking a
/// volume saves it as the project's default and routes to the
/// "Start reading?" confirmation. Otherwise, picking a volume opens the
/// books list directly (used by the project's Settings entry point).
class VolumesScreen extends ConsumerWidget {
  final StudyProject project;
  final bool isInitialSetup;
  const VolumesScreen({
    super.key,
    required this.project,
    this.isInitialSetup = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Standard Works', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              'Choose a volume to study',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: StandardWork.values.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final volume = StandardWork.values[i];
                  return _VolumeCard(
                    volume: volume,
                    onTap: () => _onVolumeTap(context, ref, volume),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onVolumeTap(
    BuildContext context,
    WidgetRef ref,
    StandardWork volume,
  ) async {
    if (isInitialSetup) {
      await ref
          .read(studyProjectsProvider.notifier)
          .setDefaultVolume(project, volume);
      if (!context.mounted) return;
      final updated = project.copyWith(defaultVolume: volume);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudyPlanCreatedScreen(
            project: updated,
            volume: volume,
          ),
        ),
      );
    } else {
      // Settings flow: also persist as new default, then jump into the books.
      await ref
          .read(studyProjectsProvider.notifier)
          .setDefaultVolume(project, volume);
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BooksScreen(
            project: project.copyWith(defaultVolume: volume),
            volume: volume,
          ),
        ),
      );
    }
  }
}

class _VolumeCard extends StatelessWidget {
  final StandardWork volume;
  final VoidCallback onTap;
  const _VolumeCard({required this.volume, required this.onTap});

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
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
